---
layout: post
title: "Class RTTI"
date: 2006-05-22 10:08
comments: true
categories: delphi
author: David Glassborow
---

This post follows up my [previous][] one about RTTI in Delphi, inspired by Hallvard's 2 posts [here][article] and 
[here][follow up], and covers some advanced RTTI features in Delphi that I haven't seen mentioned anywhere else.
<!--more-->
$METHODINFO
===========

While playing around with Websnap in Delphi, trying to extend some of the objects available for scripting, I
came across the compiler directive METHODINFO. 

The online documentation says:
>The $METHODINFO switch directive is only effective when runtime type information (RTTI) has been turned on with the 
>{$TYPEINFO ON} switch. In the {$TYPEINFO ON} state, the $METHODINFO directive controls the generation of more detailed
>method descriptors in the RTTI for methods in an interface. Though {$TYPEINFO ON} will cause some RTTI to be generated
>for published methods, the level of information is limited. The $METHODINFO directive generates much more detailed 
>(and much larger) RTTI for methods, which describes how the parameters of the method should be passed on the stack and/or in registers.
>There is seldom, if ever, any need for an application to directly use the $METHODINFO compiler switch. The method 
>information adds considerable size to the executable file, and is not recommended for general use.

My [previous][] article showed this isn't completely accurate, detailed RTTI is available for any Interface which
has $TYPEINFO or $M around it. $METHODINFO seems to affect classes, in particular it will store detailed RTTI information
for not only Published methods, but also Public ones.

Doing a search for this compiler directive in the delphi win32 source code gives us only 1 instance in WebSnapObjs.pas.

    {$METHODINFO ON}
    TScriptableObject = class(TObjectDispatch)
    private
      FLookupList: TStringList;
      FLookupValues: TInterfaceList;
    protected
      FPreferChild: Boolean;
      function DispatchOfName(const AName: string): IDispatch; virtual;
      function FindObject(const AName: string): TObject; virtual;
    public
      constructor Create;
      destructor Destroy; override;
      class function DispatchOfObject(const AObject: TObject): IDispatch;
      function GetIDsOfNames(const IID: TGUID; Names: Pointer;
        NameCount: Integer; LocaleID: Integer; DispIDs: Pointer): HRESULT;
        override;
      function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
        Flags: Word; var Params; VarResult: Pointer; ExcepInfo: Pointer;
        ArgErr: Pointer): HRESULT; override;
    end;
    {$METHODINFO OFF}


Websnap
-------

Websnap is the poor cousin in the web framework world for delphi. Its never had much support, and seems now to be
overshadow by ASP.net and Intraweb. I personally quite like it, although I code my own templates in VBScript or JavaScript
rather than use any of the Design Time webpage design stuff.

Under the hood, websnap uses the [ActiveScript][] engines provided in Windows. ActiveScript is a scripting host that can support
many different COM based scripting languages, and Windows comes with VBScript and JScript (which is basically JavaScript).
Other ActiveScript lanaguages are avaialbe including [Python][] and [Perl][].

The original ASP by Microsoft uses the ActiveScripting engine to do its work. The asp template is turned into a vBScript or
JScript program containing the HTML to output as well as the logic of the page. This is fed into the ActiveScripting engine
and compiled ready for running. The ActiveScripting engine then has 'objects' added to it so the program can do useful work.
The most obvious one is the Response object, but there are others like the Session object, etc. The program is then run and
the page rendered.

Websnap pages, at least those using a TPageProducer, use this same process to produce HTML pages. The problem for the Delphi
deisgners was how to link arbitary Delphi objects up to the ActiveScripting engine, which uses late bound IDispatch COM for
communication. The IDispatch interface, one of the main underpining of the COM framework in Windows, uses a single call,
*Invoke* for all method calls. This is where $METHODINFO comes it, the rich method RTTI is provided to allow a single procedure
entry, Invoke, to call arbitary Delphi methods.

The VBScript or Javascript script running in the scripting of the websnap page needs to talk to Delphi objects (e.g. Page,
Session), and it uses this Rich RTTI to acheive this. You can see the websnap objects that are exposed to the script, have a look in
WebSnapObjs.pas, where TResponseObj, TProducerObj, etc.

The unit ObjAuto contains the code and header for retrieving the RTTI information using the following function:

    function GetMethodInfo(Instance: TObject; const MethodName: ShortString): PMethodInfoHeader;

In turn, the base class of TScriptableObject (marked with $METHODINFO) uses the RTTI to find methods, and call them, at run time.

ObjAuto.pas
-----------

This contains the code to search for a method's RTTI. Looking at GetMethodInfo, you can see it uses the system.pas vmtMethodTable
offset to get hold the method table for the class. It then uses a search to find the correct entry. It also contains the code that
allows an arbitary call to an object supporting RTTI to jump to the correct routine:

    function ObjectInvoke(Instance: TObject; MethodHeader: PMethodInfoHeader;
      const ParamIndexes: array of Integer; const Params: array of Variant): Variant;

As you can see you just pass it parameters and variants, and it packages them into the correct types and does the call. The source
code to this call shows all the complexity of packaging up all the parameters according different conventions, etc. This is ultimately
how VBScript objects call methods on Delphi objects inside Websnap.

DetailedRTTI.pas
----------------

While playing with the metadata, I coded a few [helper classes][] to aid exploration. You can download the [code][] if you want to
have somewhere to start. Just calling .RTTIMethodsAsString() on any object to get a list of its methods and their parameters. Its a
bit rough and ready but you're welcome to use it for whatever.

Summary
=======

This article, and the [previous][] one have shown that rich metadata for methods is available in Delphi, with supporting routines
for accessing it. Interface metadata allows the VCL to support SOAP, multiple methods multiplexed to a single call. The rich class
metadata allows the VCL to support a single function automatically being routed to other methods, allowing Websnap to
expose objects to COM IDispatch automatically.


Comments (originally on blogger.com)
====================================

Hallvard Vassbotn said...

> Great posts, David!
>
> I reference them [here](http://hallvards.blogspot.com/2006/05/david-glassborow-on-extended-rtti.html)


[previous]: /blog/2006/05/11/Interface-RTTI/
[article]: http://hallvards.blogspot.com/2006/04/published-methods_27.html
[follow up]: http://hallvards.blogspot.com/2006/05/under-hood-of-published-methods.html
[helper classes]: /blog/2006/05/08/class-helpers-good-or-bad/
[code]: /images/dave/DetailedRTTI.pas
[ActiveScript]: http://msdn.microsoft.com/scripting/
[Python]: http://www.activestate.com/Products/ActivePython/
[Perl]: http://www.activestate.com/Products/ActivePerl/
