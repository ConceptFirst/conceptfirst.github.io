open System

let dispose x = (x :> IDisposable).Dispose()

module Workflow =

    /// Represents what we will tell the Twilio phone system to do
    type PhoneCommand =
    /// Connect the caller to a given phone queue
    | ConnectToQueue of queueName:string
    /// Say the message, and then hangup
    | Hangup of msg:string
    /// Say the message, then record the caller's message
    | TakeMessage of msg:string
    /// Say the message, then wait for a user to input a given number of key presses
    | WaitForKeypresses of msg:string * numberDigits:int

    /// What our workflow returns
    type CallHandlingProgram =
    | Complete   of result:PhoneCommand
    | InProgress of result:PhoneCommand * nextStep: (string -> CallHandlingProgram)

    /// Use internally for any step where we need to wait for a string
    type Internal = NeedKey of PhoneCommand

    type CallBuilder() =
        // No zero - we must return something
        member this.Return(a:PhoneCommand) = Complete a
        member this.ReturnFrom(a) = a
        member this.Bind(NeedKey(x),f) = InProgress(x, fun x -> f(x) )
    let call = new CallBuilder()
    let waitForKeypress msg num = WaitForKeypresses(msg,num) |> NeedKey

module Example =
    open Workflow
    let listQueuesAndWaitForResponse() =
        // We make this recursive so we can try a number of times before bugging out
        let rec handleQueues retries = call {
            let! keyPress = waitForKeypress "Please press 1 to discuss naughty lists, press 2 to discuss a reindeer malfunction, press 3 for any other enquires" 1
            match keyPress with
            | "1" -> return ConnectToQueue "Naughty children"
            | "2" -> return ConnectToQueue "Naughty raindeer"
            | "3" -> return ConnectToQueue "Account enquires"
            | _   -> match retries with
                     | i when i >= 3 -> return Hangup "Sorry, key not recognised"
                     | _             -> return! handleQueues (retries+1)
        }
        handleQueues 0

    let takeCall fromNumber toNumber (now:System.DateTime) =
        call {
            // 1. If the call is on Christmas Eve or later, leave a message saying we are busy
            if now.DayOfYear >= 358 then        // 358 is the 24th of December
                return Hangup "I'm sorry, we are now shut for the rest of year, happy holidays !"
            else
                // 2. If the call is out of hours, request a message is left and email it to ourselves
                // Elves are 9 to 5 workers
                if now.Hour <= 8 || now.Hour >= 17 then
                    return TakeMessage "I'm sorry, we are closed for the day, please leave a message and we'll get back to you asap"
                else
                    // 3. Offer to talk to elves, or take a mesasge
                    let! keyPress = waitForKeypress "Please press 1 to talk to one of our elves, or 2 to leave us a message" 1
                    match keyPress with
                    | "1" -> return! listQueuesAndWaitForResponse()
                    | "2" -> return TakeMessage "Please leave your message after the beep"
                    | _   -> return Hangup "Happy christmas!"
        }

module CallHandling =

    type CallDetails = {  NumberFrom:string; NumberTo:String; CallAt: DateTime }
        with static member Example = { NumberFrom = "0800 123456"; NumberTo = "01-DIAL-SANTA"; CallAt = DateTime(2000,01,01) }

    type CallResponse =
        | CompletedResponse of Workflow.PhoneCommand
        | IntermediateResponse of Workflow.PhoneCommand

    type internal CallHandlerMessages =
        | CallStarted of AsyncReplyChannel<CallResponse>
        | DigitsProvided of string * AsyncReplyChannel<CallResponse>
        | PersistToStorage

    type internal CallHandlerState = {
        CurrentProgram: (string -> Workflow.CallHandlingProgram) option
        Digits: string list
    } with static member NotStarted = { CurrentProgram = None; Digits = [] }

    type CallHandler(callDetails: CallDetails, persistAfter: TimeSpan) =
        let getProgram() = Example.takeCall callDetails.NumberFrom callDetails.NumberTo callDetails.CallAt

        let stepProgram reply state program =
            match program with
            | Workflow.Complete(resp) ->
                CompletedResponse(resp) |> reply
                state
            | Workflow.InProgress(resp,next) ->
                IntermediateResponse(resp) |> reply
                { state with CurrentProgram = Some next }

        let resurrectViaReplay digitHistory =
            let replayError _ = Workflow.Complete (Workflow.Hangup "Failed to replay history")
            let state = CallHandlerState.NotStarted
            let rec stepDigits keyPresses program =
                match keyPresses with
                | []         -> program
                | key::other -> match (stepProgram ignore state (program key)).CurrentProgram with
                                | None -> replayError
                                | Some s -> stepDigits other s
            let nextStep = match (stepProgram ignore state <| getProgram()).CurrentProgram with
                           | None -> replayError
                           | Some p -> p
            nextStep |> stepDigits (List.rev digitHistory)

        let agent = MailboxProcessor<_>.Start( fun inbox ->
            let rec messageLoop (state: CallHandlerState) = async {
                let! message = inbox.TryReceive(int persistAfter.TotalMilliseconds)
                let newState =
                    match message with
                    | Some (CallStarted(caller)) ->
                        stepProgram caller.Reply state <| getProgram()
                    | Some (DigitsProvided(digits,caller)) ->
                        let program = match state.CurrentProgram with
                                      | Some program -> program
                                      | None   ->       resurrectViaReplay state.Digits
                        let state' = stepProgram caller.Reply state <| program(digits)
                        { state' with Digits = digits :: state'.Digits }  // store for later replay if needed
                    | Some PersistToStorage | None ->
                        // production version: persist state.Digits to secure storage
                        { state with CurrentProgram = None  }
                return! messageLoop newState }
            messageLoop CallHandlerState.NotStarted )
        member x.StartSync() = agent.PostAndReply( CallStarted )
        member x.StepSync(digits) = agent.PostAndReply( fun caller -> DigitsProvided(digits,caller) )
        member internal x.DirectPost(msg) = agent.Post(msg) // For use by the switchboard to post directly to the agent
        interface IDisposable with member __.Dispose() = dispose agent

module SwitchBoard =

    /// The protocol definiton for interacting with the switch board agent
    type private SwitchBoardProtocol<'Id,'Handler when 'Id: comparison and 'Handler :> IDisposable> =
        | StoreHandler     of id:'Id * handler:'Handler
        | FindHandler      of id:'Id * reply: AsyncReplyChannel<'Handler option>
        | RemoveHandler    of id:'Id    // This is also responsible for disposing the object
        | RequestOfHandler of id:'Id * toRun:( Result<'Handler,string> -> unit )

    /// Object responsible for finding and routing calls to handler by id
    /// This is essentially a thread safe Map of handlers which handles disposal
    type Switchboard<'Id,'Handler when 'Id: comparison and 'Handler :> IDisposable>() =
        let agent = MailboxProcessor<_>.Start( fun inbox ->
            let rec messageLoop (state: Map<'Id,'Handler>) = async {
                let! message = inbox.Receive()
                let newState = match message with
                               | StoreHandler(id, handler) ->
                                    state.Add(id,handler)
                               | RemoveHandler(id) -> match state.TryFind(id) with
                                                      | None -> state
                                                      | Some handler ->
                                                        dispose handler
                                                        state.Remove(id)
                               | FindHandler(id, channel) ->
                                    state.TryFind(id) |> channel.Reply
                                    state
                               | RequestOfHandler(id,f) -> match state.TryFind(id) with
                                                           | None ->
                                                               Error("Cannot find callId") |> f
                                                               state
                                                           | Some h ->
                                                               Ok(h) |> f
                                                               state
                return! messageLoop newState
            }
            messageLoop Map.empty   // Kick off the message loop with no open calls
        )
        interface IDisposable with member x.Dispose() = dispose agent
        member x.StoreHandler(id,handler) = StoreHandler(id,handler) |> agent.Post
        member x.FindHandler(id) = agent.PostAndReply( fun channel -> FindHandler(id,channel) )  // TODO: move to Async
        member x.RemoveHandler(id) = RemoveHandler(id) |> agent.Post
        member x.RequestOfHandler(id, getF) = agent.PostAndReply(fun channel -> RequestOfHandler(id, getF channel ))

module HttpEndpoint =
    open CallHandling
    open SwitchBoard
    type HttpHandler(autoStoreTimeout) =
        let switchBoard = new Switchboard<_,_>()
        interface IDisposable with member x.Dispose() = dispose switchBoard

        member x.StartCall(callId:string, numberFrom, numberTo,callAt) =
            // create new object, get first response.
            let handler = new CallHandler( { NumberFrom = numberFrom; NumberTo = numberTo; CallAt = callAt }, autoStoreTimeout)
            match handler.StartSync() with
            | CompletedResponse details as resp ->
                resp // If complete we are done, note: we return the the resp to aid testing, in real life we would return details
            | IntermediateResponse details as resp ->
                do switchBoard.StoreHandler(callId,handler) // We are not done, so store the handler for next time
                resp

        member x.StepCall(callId,digits) =
            let handler = switchBoard.FindHandler(callId)
            match handler with
            | None -> Workflow.Hangup "Unknown call" |> CompletedResponse
            | Some handler ->
                match handler.StepSync(digits) with
                | IntermediateResponse details as resp -> resp
                | CompletedResponse details as resp    ->
                    // We are done so remove handler
                    do switchBoard.RemoveHandler(callId)
                    do (handler :> IDisposable).Dispose()
                    resp

        member x.StepCallForwarded(callId,digits) =
            // Rather than lookup the handler then call it, just ask the switchboard to pass the message straight through
            let stepResult = switchBoard.RequestOfHandler(callId, fun channel ->
                function
                | Ok (handler:CallHandler) -> handler.DirectPost( CallHandlerMessages.DigitsProvided(digits,channel) )
                | Error err                -> channel.Reply(CallResponse.CompletedResponse (Workflow.Hangup err)))
            match stepResult with
            | IntermediateResponse details as resp -> resp
            | CompletedResponse details as resp    ->
                // We are done so remove handler
                do switchBoard.RemoveHandler(callId)
                resp

module Testing =
    open CallHandling
    open Workflow

    let private runTestScenarios simulateCall name =
        let (=?) a b =
            if a <> b then failwithf "%A does not equal %A" a b;

        simulateCall (DateTime(2017,12,24)) [] =?
            [ Hangup "I'm sorry, we are now shut for the rest of year, happy holidays !"]

        simulateCall (DateTime(2017,12,22,17,0,0)) [ ] =?
            [ TakeMessage "I'm sorry, we are closed for the day, please leave a message and we'll get back to you asap"]

        simulateCall (DateTime(2017,12,22,12,0,0)) [ "2" ] =?
            [ WaitForKeypresses("Please press 1 to talk to one of our elves, or 2 to leave us a message", 1)
              TakeMessage "Please leave your message after the beep"]

        simulateCall (DateTime(2017,12,22,12,0,0)) [ "1"; "4"; "4"; "2" ] =?
            [ WaitForKeypresses("Please press 1 to talk to one of our elves, or 2 to leave us a message", 1)
              WaitForKeypresses("Please press 1 to discuss naughty lists, press 2 to discuss a reindeer malfunction, press 3 for any other enquires",1)
              WaitForKeypresses("Please press 1 to discuss naughty lists, press 2 to discuss a reindeer malfunction, press 3 for any other enquires",1)
              WaitForKeypresses("Please press 1 to discuss naughty lists, press 2 to discuss a reindeer malfunction, press 3 for any other enquires",1)
              ConnectToQueue "Naughty raindeer"]

        printfn "%s - all passed" name

    let private defaultAutoStoreTime = TimeSpan.FromSeconds(30.)

    let testCallAgent() =
        let runCallViaAgent dt listOfKeyPresses =
            use call = new CallHandler({ CallDetails.Example with CallAt = dt }, defaultAutoStoreTime)
            let rec runIt listOfKeyPresses = function
                | CompletedResponse r    -> [r]
                | IntermediateResponse r -> match listOfKeyPresses with
                                            | [] -> failwith "Run out of input keys"
                                            | keysPressed::futureKeys ->  r :: runIt futureKeys (call.StepSync keysPressed)
            call.StartSync() |> runIt listOfKeyPresses
        do runTestScenarios runCallViaAgent "CallHandler direct"

    let testHttp() =
        let runCallViaHTTP dt listOfKeyPresses =
            use http = new HttpEndpoint.HttpHandler(defaultAutoStoreTime)
            let details = { CallDetails.Example with CallAt = dt }
            let callId = Guid.NewGuid().ToString()
            let rec runIt listOfKeyPresses = function
                | CompletedResponse r    -> [r]
                | IntermediateResponse r -> match listOfKeyPresses with
                                            | [] -> failwith "Run out of input keys"
                                            | keysPressed::futureKeys ->  r :: runIt futureKeys (http.StepCall(callId,keysPressed))
            http.StartCall(callId,details.NumberFrom,details.NumberTo,details.CallAt) |> runIt listOfKeyPresses
        do runTestScenarios runCallViaHTTP "Via switchboard"

    let testHttpForwarded() =
        let runCallViaHTTP dt listOfKeyPresses =
            use http = new HttpEndpoint.HttpHandler(defaultAutoStoreTime)
            let details = { CallDetails.Example with CallAt = dt }
            let callId = Guid.NewGuid().ToString()
            let rec runIt listOfKeyPresses = function
                | CompletedResponse r    -> [r]
                | IntermediateResponse r -> match listOfKeyPresses with
                                            | [] -> failwith "Run out of input keys"
                                            | keysPressed::futureKeys ->  r :: runIt futureKeys (http.StepCallForwarded(callId,keysPressed))
            http.StartCall(callId,details.NumberFrom,details.NumberTo,details.CallAt) |> runIt listOfKeyPresses
        do runTestScenarios runCallViaHTTP "Switchboard with forwarding"

    let testRewind() =
        let runCallViaAgent dt listOfKeyPresses =
            use call = new CallHandler({ CallDetails.Example with CallAt = dt }, defaultAutoStoreTime)
            let rec runIt listOfKeyPresses = function
                | CompletedResponse r    -> [r]
                | IntermediateResponse r -> match listOfKeyPresses with
                                            | [] -> failwith "Run out of input keys"
                                            | keysPressed::futureKeys ->
                                                call.DirectPost( PersistToStorage ) // Every new call, tell the agent to persist and reforce replay
                                                r :: runIt futureKeys (call.StepSync keysPressed)
            call.StartSync() |> runIt listOfKeyPresses
        do runTestScenarios runCallViaAgent "CallHandler direct with rewind"

#time
Testing.testCallAgent()
Testing.testHttp()
Testing.testHttpForwarded()
Testing.testRewind()
