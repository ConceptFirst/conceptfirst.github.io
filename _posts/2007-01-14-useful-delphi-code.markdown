---
layout: post
title: "Useful Delphi Code"
date: 2007-01-14 15:35
comments: true
categories: delphi
author: David Glassborow
---
Just realised I haven't written a blog post for 2.5 months, and I've just got back from a lunchtime surfing session, so I'm not really in the mood for real work.
I thought I'd post some of my basic Delphi library code I use time and again in the hope it is of some use to other Delphi developers. Do what ever you want with it, I don't guarantee its without bugs, but most of it has been used in production code for quite a long time.
<!--more-->
The full file with all the implementation can be found here: [Source][]

The following are useful for conditional logic for development vs production code, debugging, etc.:

    procedure BreakpointInIDE;
    function CurrentExceptionMessage: string;
    function IsRunningUnderIDE: boolean; inline;    
    
The following function is useful for preventing the unsitely errors that can occur as a Delphi Application throws Exceptions as it shuts down. While ideally this should never happen, previous exceptions can leave forms in a have constructed state, and the TApplication's attempt to clean up them then causes horrible dialogs frightening users. Even the IDE has been known to do this. The code hooks the various Exception raised pointed in the RTL to silently ignore the errors. If running inside the IDE, it will also post a message to the event log, and cause the IDE to breakpoint to highlight there is an issue.

    procedure HookShutdownToHideExceptions;    
    
[Helper Classes][] for TList, TStream and TStrings. In particular I use the ID accessors of TStrings a lot when putting records into UI elements. Makes it very easy to look up the ID of the record in a combo box, for example. It uses the Object field in a list item to store the ID. Helpers require at least Delphi 2006.

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
      function RewindToStart: TStream;                                      // Returns self to allow easy chaining of calls
      procedure WriteString( const Text: string );
      procedure WriteStringAndBreak( const Text: string );
    end;

The following two classes are 2 example simple container objects based on records rather than classes. The nice thing is they don't have to be memory managed like classes do, the compiler will handle all of that for you. They are not as fully featured as string lists, but are useful for simple tasks. They are also reasonabilly efficient, as the dyanmic arrays they use are copy by reference. The only thing to remember is to use the Clone method if you actually want a whole new copy of the data. I have about 4 or 5 different variants of these to store ID => Name, Name => Variant, etc, but you get the idea.

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

Here is a simple subclass of Exception to allow Assertions on any Exception derived object. I tried to do this via a helper class, but the 'self' object in a class level helper called on a class does not appear to be a valid reference, so I couldn't find a way to get it to work. Looking through the code to Indy inspired this approach to using Exceptions, I never use the raise statement anymore.

    EBase = class( Exception )
      class procedure Assert( Test: boolean; const Msg: string );
      class procedure Throw( const Msg: string ); virtual;
    end;

The last function is `function ShowHourglass: IUnknown;` This can be called in a UI function to make a form show a cursor, and when the function exits (normally or after an exception) be sure the cursor is returned to its previous state. The return value (IUnknwon) does not need to be stored, behind the scenes Delphi will store it anyway and make sure the compiler puts a hidden Try ... Finally in at the end to make sure it is cleaned up. The cleaning up of the interface is what we use to reset the cursor.

Anyway hopefully this of some use to somebody. Happy New Year to everyone, here's to a good year from CodeGear.

[Helper Classes]: /blog/2006/05/08/class-helpers-good-or-bad/
[Source]: /images/dave/blog.pas