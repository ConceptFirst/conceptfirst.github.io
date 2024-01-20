unit blog;

 { License: Do what ever you want with it, but don't blame me if anything's is wrong .... }

interface

uses
  Classes,
  SysUtils;

procedure BreakpointInIDE;
function CurrentExceptionMessage: string;
procedure HookShutdownToHideExceptions;
function IsRunningUnderIDE: boolean; inline;
function ShowHourglass: IUnknown;

{ Class Helpers }

type
  ID = cardinal;

  TListHelper = class helper for TList
    procedure FreeSelfAndContainedObjects;
  end;

  TStringsHelper = class helper for TStrings
  private
    function GetID(Index: Integer): ID;
    procedure SetID(Index: Integer; const Value: ID);
    function GetDescFromID(ID: ID): string;
    function GetIDFromDesc(const Desc: string): ID;
    function GetObjectByString(text: string): TObject;
  public
    function AddPair(const Name, Value: string): integer;
    function AddID(const Desc: string; PrimaryKey: ID): Integer;
    function AddObj( const Name, Value: string; Obj: TObject ): Integer;
    function ContainsKey( const Key: string ): boolean;
    function ContainsString( const Text: string ): boolean;
    function ContainsValue( const Value: string ): boolean;
    procedure FreeSelfAndContainedObjects;
    function IndexOfID( ID: ID ): integer;
    property DescFromID[ID:ID]: string read GetDescFromID;
    property IDFromDesc[const Desc: string]: ID read GetIDFromDesc;
    property IDs[Index: Integer]: ID read GetID write SetID;
    property ObjectByString[ text: string ]: TObject read GetObjectByString;
  end;

  TStreamHelper = class helper for TStream
  public
    function AsString: string;
    function RewindToStart: TStream;                                      // Returns self to allow easy chaining
    procedure WriteString( const Text: string );
    procedure WriteStringAndBreak( const Text: string );
  end;

{ Simple container records }

  TSimpleStringList = record
  private
    FItems: array of string;
    function  GetCount: integer; inline;
    function  GetItem(index: integer): string;
    procedure SetItem(index: integer; const Value: string);
  public
    function  Add(const line: string): integer;
    procedure Clear;
    function  Clone: TSimpleStringList;
    function  Contains(const s: string): boolean;
    function  IndexOf(const s: string): integer;
    function  IsMissing(const s: string): boolean;
    property  Count: integer read GetCount;
    property  Items[index: integer]: string read GetItem write SetItem; default;
  end;

  TSimpleStringListHelper = record helper for TSimpleStringList
  public
    function AsNewStringList: TStringList;
    function StringsCommaSeperated: string;
  end;

  TSimpleDictionary = record
  private
    FKeys: array of string;
    FValues: array of string;
    function GetCount: integer; inline;
    function GetKey(index: integer): string;
    function GetValue(const Key: string): string;
    function GetValueByIndex(index: integer): string;
    procedure SetKey(index: integer; const Value: string);
    procedure SetValue(const Key, Value: string);
    procedure SetValueByIndex(index: integer; const Value: string);
  public
    function  Add(const Key, Value: string): integer;
    function AsNewStringList: TStringList;
    procedure AddStrings(Strings: TStrings);
    procedure Clear;
    function Clone: TSimpleDictionary;
    function ContainsKey(const Key: string): boolean;
    function IndexOfKey(const Key: string): integer;
    function IndexOfValue(const Value: string): integer;
    property Count: integer read GetCount;
    property Keys[index: integer]: string read GetKey write SetKey;
    property Values[const Name: string]: string read GetValue write SetValue; default;
    property ValueFromIndex[ index: integer ]: string read GetValueByIndex write SetValueByIndex;
  end;

  TSimpleDictionaryHelper = record helper for TSimpleDictionary
  public
    function KeysCommaSeperated: string;
    function SemicolonDelimitedString: string;
    procedure LoadFromSemiColonDelimitedString( Text: string );
    procedure LoadFromStringList( StringList: TStringList );
    function Text: string;
    function ValueOrDefault( const Key: string; const Default: string ): string;
  end;


implementation

uses
  Controls, Forms, Graphics, Windows;

type
  EBase = class( Exception )
    class procedure Assert( Test: boolean; const Msg: string );
    class procedure Throw( const Msg: string ); virtual;
  end;

  ELib = class( EBase );                          // Exception for library code

function IsRunningUnderIDE: boolean; inline;
begin
  Result := System.DebugHook <> 0;
end;

procedure BreakpointInIDE;
asm
  int 3;                                        // Machine code for causing a debugger to breakpoint
end;

function CurrentExceptionMessage: string;
begin
  if ( ExceptObject = nil ) or not ( ExceptObject is Exception ) then
    result := 'Unknown message for current exception'
  else
    result := Exception( ExceptObject ).Message;
end;

{ TListHelper }

procedure TListHelper.FreeSelfAndContainedObjects;
var
  i: integer;
begin
  if Self = nil then exit;
  for i := 0 to Self.Count - 1 do
    TObject(Self[i]).Free;
  Self.Free;
end;

{ TStringsHelper }


function TStringsHelper.AddObj(const Name, Value: string; Obj: TObject): Integer;
begin
  Result := Self.AddObject( Name + self.NameValueSeparator + Value, Obj );
end;

function TStringsHelper.ContainsKey(const Key: string): boolean;
begin
  Result := self.IndexOfName(Key) <> -1;
end;

function TStringsHelper.ContainsString(const Text: string): boolean;
begin
  Result := self.IndexOf(Text) <> -1;
end;

function TStringsHelper.ContainsValue(const Value: string): boolean;
var
  i: integer;
begin
  Result := True;
  for i := 0 to self.Count - 1 do
    if SameText( self.ValueFromIndex[i], Value ) then exit;
  Result := False;
end;

procedure TStringsHelper.FreeSelfAndContainedObjects;
var
  i: integer;
begin
  if Self = nil then exit;
  for i := 0 to Self.Count - 1 do
    Self.Objects[i].Free;
  Self.Free;
end;

function TStringsHelper.AddPair(const Name, Value: string): integer;
begin
  Result := self.Add( Name + self.NameValueSeparator + Value );
end;

function TStringsHelper.AddID(const Desc: string; PrimaryKey: ID): Integer;
begin
  // Store in the object pointer
  result := AddObject(Desc, TObject(PrimaryKey));
end;

function TStringsHelper.GetDescFromID(ID: ID): string;
var
  index: integer;
begin
  index := IndexOfObject( TObject(ID) );
  ELib.Assert( index <> -1, 'Cannot find ID ' + IntToStr(ID) + ' in List' );
  result := Strings[ index ];
end;

function TStringsHelper.GetID(Index: Integer): ID;
begin
  result := ID( Objects[index] );
end;

function TStringsHelper.GetIDFromDesc(const Desc: string): ID;
begin
  result := IDs[IndexOf(Desc)];
end;

function TStringsHelper.GetObjectByString(text: string): TObject;
begin
  result := Objects[ self.IndexOf(text) ];
end;

function TStringsHelper.IndexOfID(ID: ID): integer;
begin
  result := IndexOfObject( TObject(ID) );
end;

procedure TStringsHelper.SetID(Index: Integer; const Value: ID);
begin
  Objects[ index ] := TObject( value );
end;

{ TStreamHelper }

function TStreamHelper.AsString: string;
begin
  SetLength( Result, self.Size );
  self.Position := 0;     // Go to start
  if Length(Result) > 0 then Read( Result[1], Length(Result) );
end;

function TStreamHelper.RewindToStart: TStream;
begin
  Position := 0;
  Result := self;
end;

procedure TStreamHelper.WriteString(const Text: string);
begin
  if Length(Text) = 0 then exit;
  Write( Text[1], Length(Text) );
end;

procedure TStreamHelper.WriteStringAndBreak(const Text: string);
begin
  WriteString(Text);
  WriteString(sLineBreak);
end;

{ TStringListRecord }

function TSimpleStringList.Add(const line: string): integer;
begin
  SetLength(FItems,Count+1);
  FItems[Count-1] := line;
  result := Count - 1;
end;

procedure TSimpleStringList.Clear;
begin
  SetLength( FItems, 0 );
end;

function TSimpleStringList.Clone: TSimpleStringList;
begin
  Result := self;
  Result.FItems := Copy( self.FItems );
end;

function TSimpleStringList.Contains(const s: string): boolean;
begin
  Result := IndexOf(s) <> -1;
end;

function TSimpleStringList.GetCount: integer;
begin
  result := length(FItems);
end;

function TSimpleStringList.GetItem(index: integer): string;
begin
  result := FItems[index];
end;

procedure TSimpleStringList.SetItem(index: integer; const Value: string);
begin
  FItems[index] := Value;
end;

function TSimpleStringList.IndexOf(const s: string): integer;
var
  k: integer;
begin
  result := -1;
  for k := 0 to Count - 1 do begin
    if SameText(FItems[k], s) then begin
      result := k;
      break;
    end;
  end;
end;

function TSimpleStringList.IsMissing(const s: string): boolean;
begin
  Result := not Contains(s);
end;

{ TSimpleStringListHelper }

function TSimpleStringListHelper.AsNewStringList: TStringList;
var
  i: Integer;
begin
  Result := TStringList.Create;
  for i := 0 to Count - 1 do
    Result.Add( Items[i] );
end;

function TSimpleStringListHelper.StringsCommaSeperated: string;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Result := Result + Items[i] + ',';
  Delete( Result, Length(Result), 1 );
end;

{ TSimpleDictionary }

function TSimpleDictionary.Add(const Key, Value: string): integer;
begin
  Result := Count;
  SetLength(FKeys, Result + 1 );
  SetLength(FValues, Result + 1 );
  FKeys[Result] := Key;
  FValues[Result] := Value;
end;

procedure TSimpleDictionary.AddStrings(Strings: TStrings);
var
  i: Integer;
begin
  for i := 0 to Strings.Count - 1 do
    Add( Strings.Names[i], Strings.ValueFromIndex[i] );
end;

function TSimpleDictionary.AsNewStringList: TStringList;
var
  i: Integer;
begin
  Result := TStringList.Create;
  for i := 0 to Count - 1 do
    Result.AddPair( self.Keys[i], self.ValueFromIndex[i] );
end;

procedure TSimpleDictionary.Clear;
begin
  SetLength(FKeys,0);
  SetLength(FValues,0);
end;

function TSimpleDictionary.Clone: TSimpleDictionary;
begin
  Result := self;
  Result.FKeys := Copy( Self.FKeys );
  Result.FValues := Copy( self.FValues );
end;

function TSimpleDictionary.ContainsKey(const Key: string): boolean;
begin
  Result := IndexOfKey( Key ) <> -1;
end;

function TSimpleDictionary.GetCount: integer;
begin
  Result := Length( FKeys );
end;

function TSimpleDictionary.GetKey(index: integer): string;
begin
  Result := FKeys[index];
end;

function TSimpleDictionary.GetValue(const Key: string): string;
var
  index: integer;
begin
  index := IndexOfKey(Key);
  ELib.Assert( index <> -1, 'SimpleDictionary - Unknown key ' + Key);
  Result := ValueFromIndex[ index ];
end;

function TSimpleDictionary.GetValueByIndex(index: integer): string;
begin
  Result := FValues[index];
end;

function TSimpleDictionary.IndexOfKey(const Key: string): integer;
begin
  for Result := Low(FKeys) to High(FKeys) do
    if SameText( FKeys[Result], Key ) then exit;
  Result := -1;
end;

function TSimpleDictionary.IndexOfValue(const Value: string): integer;
begin
  for Result := Low(FValues) to High(FValues) do
    if SameText( FValues[Result], Value ) then exit;
  Result := -1;
end;

procedure TSimpleDictionary.SetKey(index: integer; const Value: string);
begin
  FKeys[index] := Value;
end;

procedure TSimpleDictionary.SetValue(const Key, Value: string);
var
  i: integer;
begin
  i := IndexOfKey(Key);
  if i = -1 then
    Add(Key, Value)
  else
    FValues[ i ] := Value;
end;

procedure TSimpleDictionary.SetValueByIndex(index: integer; const Value: string);
begin
  FValues[index] := Value;
end;

{ TSimpleDictionaryHelper }

function TSimpleDictionaryHelper.KeysCommaSeperated: string;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Result := Result + Keys[i] + ',';
  Delete( Result, Length(Result), 1 );
end;

procedure TSimpleDictionaryHelper.LoadFromSemiColonDelimitedString( Text: string);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Delimiter := ';';
    sl.DelimitedText := Text;
    LoadFromStringList(sl);
  finally
    sl.Free;
  end;
end;

procedure TSimpleDictionaryHelper.LoadFromStringList( StringList: TStringList );
var
  i: integer;
begin
  self.Clear;
  for i := 0 to StringList.Count - 1 do
    self.Add( StringList.Names[i], StringList.ValueFromIndex[i] );
end;

function TSimpleDictionaryHelper.SemicolonDelimitedString: string;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Result := Result + Keys[i] + '=' + ValueFromIndex[i] + ';';
  Delete( Result, Length(Result), 1 );
end;

function TSimpleDictionaryHelper.Text: string;
begin
  with self.AsNewStringList do
  begin
    Result := Text;
    Free;
  end;
end;

function TSimpleDictionaryHelper.ValueOrDefault(const Key, Default: string): string;
var
  index: integer;
begin
  index := self.IndexOfKey(Key);
  if index = -1 then Result := Default else Result := Self.ValueFromIndex[index];
end;

{ EBase }

class procedure EBase.Assert(Test: boolean; const Msg: string);
begin
  if not Test then Throw( Msg );
end;

class procedure EBase.Throw(const Msg: string);
begin
  raise Create( Msg );
end;

type
  HourglassHandler = class(TInterfacedObject)
  private
    FOldCursor: TCursor;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{ HourglassHandler }

constructor HourglassHandler.Create;
begin
  FOldCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
end;

destructor HourglassHandler.Destroy;
begin
  Screen.Cursor := FOldCursor;
  inherited;
end;

function ShowHourglass: IUnknown;
begin
  result := HourglassHandler.Create
end;

type
  TTerminateCleanly = class
  private
    procedure OnException( Sender: TObject );
    procedure OnException2(E: Exception);
    procedure OnAppException(Sender: TObject; E: Exception);
  end;

procedure TTerminateCleanly.OnException(Sender: TObject);
var
  msg: string;
begin
  if IsRunningUnderIDE then
  begin
    if Sender is Exception then msg := Exception(Sender).Message;
    OutputDebugString(PChar(msg));
    asm
      int 3;                                        // This shouldn't happen, so let the developer see the issue !
    end;
  end;
end;

procedure TTerminateCleanly.OnException2(E: Exception);
begin
  OnException(E);
end;

procedure TTerminateCleanly.OnAppException(Sender: TObject; E: Exception);
begin
  OnException(E);
end;

var
  terminationObject: TTerminateCleanly = nil;

function OnCalledByAppTerminate: boolean;
begin
  Result := True;                                                 // Tell the app we are happy to shut down
  if terminationObject <> nil then exit;                          // Already been called
  terminationObject := TTerminateCleanly.Create;
  ApplicationShowException := terminationObject.OnException2;     // Classes, but hooked by TApplication
  ApplicationHandleException := terminationObject.OnException;    // TDataModules
  Application.OnException := terminationObject.OnAppException;
end;

procedure HookShutdownToHideExceptions;
begin
  Sysutils.AddTerminateProc( OnCalledByAppTerminate );
end;

initialization

finalization

  terminationObject.Free;

end.
