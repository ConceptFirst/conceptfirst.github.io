---
layout: post
title: "Interface RTTI"
date: 2006-05-11 10:08
comments: true
categories: delphi
author: David Glassborow
---
Reading an [article][] and its [follow up][] by Hallvard about RTTI inspired me to put together a couple of posts about two 
related areas of RTTI in Delphi. In particular one of the comments on Hallvard's blog about using this RTTI to call 
objects in some late bound fashion. This post and the next cover some of the advanced RTTI that I haven't seen covered
in other places. This post covers some of the possibilities for Interface metadata, and the next one will contain
details about richer [class RTTI][] for methods.
<!--more-->
Interface Metadata
==================

Delphi actually has richer metadata support for methods in an Interface that in a normal class. It looks like this was added
to support the SOAP features of the VCL. I'm not sure which version of Delphi it was added so your mileage may
vary if your not using 2006.

IInvokable
----------

To use SOAP, you use a WDSL file to specify the method calls, parameters, etc.
If you import a WSDL in Delphi, you will notice that all Interfaces in the generated file will be derived from IInvokable.
A quick peak in the System unit will show that IInvokable is:

    {$M+}
      IInvokable = interface(IInterface)
      end;
    {$M-}

I.e. just a standard interface, but with RTTI metadata compiled in.

Looking at the help in BDS 2006 for {$TYPEINFO ON} mentions this:

> Note: 
> The IInvokable interface defined in the System unit is declared in the {$M+} state, so any interface derived 
> from IInvokable will have RTTI generated. The routines in the IntfInfo unit can be used to retrieved the RTTI.
 

IntfInfo.pas
------------

The main procedure of interest in IntIfnfo is:

    procedure GetIntfMetaData(Info: PTypeInfo; var IntfMD: TIntfMetaData; IncludeAllAncMethods: Boolean = False);

This will give us a series of records describing the methods on the interface and the parameters needed for these interfaces, as
well as the unit it was defined within, the ancestor Interface and the interface's GUID. All the names are available. both
function / procedures and the names of their parameters. Calling this procedure with an interface not having RTTI will 
raise an exception, calling it with a class's typeinfo will just cause an a/v :-)

When doing SOAP calls, the developer just uses the defined interface like a normal interface.
Behind the scenes, Delphi packages up the parameters and sends them via a SOAP envelope to the remote server.
How Delphi does this shows us some of the potential of this RTTI in Delphi, and respect for the *Voodoo* that is TRIO.

RIO.pas
-------

Located in the soap folder of Delphi's source code, RIO.pas contains the class TRIO. TRIO is an object that represents
a remote object, presumably it stands for Remote Interfaced Object.

> When an application casts a TRIO descendant to a registered invokable interface, it dynamically generates
> an in-memory method table, providing an implementation to that invokable interface.

Looking at the source for TRIO, I've come to the conclusion that:

    MyRioObject as IMyInvokableInterface

Will cause the TRio object to

1. Get the meta data for IMyInvokableInterface (from a registry InvRegistry object defined in InvokeRegistry.pas)
2. Allocate memory for a vtable for the interface
3. Allocate memory for 'stub' routines, marks it as containing executable code
3. Writes machine code stubs that takes the parameters and packages them up, then calls TRIO.Generic

This is a very crude representation I knocked up in Visio: 

![image][]

When you then make a call on the 'generated' interface, Delphi calls the vtable, the vtables holds the address of the
generated machine code. The generated machine code pushes the parameters then calls the Generic function. This packages
up the parameters, and then uses a SOAP call to call the remote service. The return is then packaged up and returned
in a similar way, back through the generated stub. If you are interested in how the actual machine code
is generated (taking into account the 5 different calling conventions, etc.) take a look at TRIO.GenVTable function.

I don't know which of the Delphi team wrote this code, but its very very impressive. 

Anyway I hope this has given you a feel for some of the advanced metadata available with Interfaces. The RIO
approach would allow you to write Interface proxies of any Interface with metadata, for security, logging and indeed other
forms of RPC remoting. Let me know if anybody succeeds in such a thing !

My followup article on [class RTTI][].

[article]: http://hallvards.blogspot.com/2006/04/published-methods_27.html
[follow up]: http://hallvards.blogspot.com/2006/05/under-hood-of-published-methods.html
[class RTTI]: /blog/2006/05/22/Class-RTTI/
[image]: /images/dave/InterfaceRTTI.gif
