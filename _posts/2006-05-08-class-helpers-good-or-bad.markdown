---
layout: post
title: "Class Helpers: Good or Bad ?"
date: 2006-05-08 23:08
comments: true
categories: delphi
author: David Glassborow
---
One of the things I love about the latest versions of Delphi is the compiler changes, originally made for .Net, that
are being rolled back into Win32 code. I like finally having procedures in records, and I love class helpers.

Class Helpers
=============

Helper classes were introduced in Delphi 8 as a way of binding the VCL to the .Net framework. To quote the Delphi 
help: "Class helpers are a way to extend a class without using inheritance. 
A class helper simply introduces a wider scope for the compiler to use when resolving identifiers."

Very simply, they allow you to add your own code to existing objects without requiring the source code or recompiling.
The new code only has public access to the original object, so it cannot access private or protected data.
<!--more-->
A simple example from my library code:

    TStreamHelper = class helper for TStream
    public
      function AsString: string;
      procedure WriteString( const Text: string );
      procedure WriteStringAndLineBreak( const Text: string );
    end;

I got bored of writing the same code for writing a string to a stream, so I put it into a class helper, and because
TStream is a base class, it works for TFileStreams, TBlobStreams, whatever.

Really a class helper is a compiler trick, behind the scenes it is just functions operating on the class, but it doesn't polute
the name space, and works with intellisense. I find myself using them more and more. The other day I was writing some code to
do a gradient fill for a custom background. Very quickly the code became a helper function on the TCanvas object.
Some more examples from my company's library code:

    TCanvasHelper =  class helper for TCanvas
      procedure FillGradient( Bounds: TRect; StartColour, EndColour: TColor; IsHorizontal: boolean );
    end;

    TListHelper = class helper for TList
      procedure FreeSelfAndContainedObjects;
    end;

    TDatasetHelper = class helper for TDataSet
    public
      procedure InsertIntoStrings( Strings: TStrings; NameField: string; IndexField: string = '' );
      function HaveFieldsChanged: boolean;
      procedure PostIfEditing;
    end;

    TFieldHelper = class helper for TField
    public
      function HasChanged: boolean;
    end;

    TTreeNodesHelper = class helper for TTreeNodes
    public
      procedure ExpandToLevel( Level: integer );
      function FindOrCreateNode( NodePath: string ): TTreeNode;
    end;
  
    TRectHelper = record helper for TRect
      function ContainsPoint( Point: TPoint ): boolean;
    end;

Note: the last example shows that, at least in BDS 2006, you can also write helpers for records.


Bad Design
----------

Reading the rest of the Borland help on class helpers, you come to this statement: 

> Class helpers provide a way to extend a class, but they should not be viewed as a design tool to be used 
> when developing new code. They should be used solely for their intended purpose, which is language and 
> platform RTL binding.

I don't agree with this, they are far more useful than just a trick for "language and platform RTL binding"


Humane Interfaces
=================

Recently I was reading some content on [Martin Fowler](http://www.martinfowler.com/bliki/)'s website, a site
that always has an interesting perspective on software development. One of his articles that struck a 
cord was on "Humane vs Minimalist" interfaces.

To briefly summarise his [article](http://www.martinfowler.com/bliki/HumaneInterface.html), he talks about the 
different attitude between Ruby developers, who favour rich easy to use interfaces, compared to the Java 
crowd who tend to favour minimal interfaces. The example he gives is of a list class and how to get the last item:

Java: 

    aList.get(aList.size -1)

Ruby:

    anArray.last

The Ruby interface has 78 methods, the Java one 25. However the Ruby one is clearly more readable, with less visual clutter.

At Concept First our 2 overriding rules for writing code are:

1. It should be as human readable as possible
2. It should be as concise as possible

For this reason I favour the humane interfaces. However writing minimalist interfaces I feel leads to more concise design and less
easier to test. It seems to me that class helpers give us the best of both worlds. Objects can be designed with minimal
interfaces, making them quicker to develop and easier to test. We can then use class helpers to make the 
interfaces more humane, more readable, easier to use. The fact that class helpers can only use public 
methods of the object also makes sure the minimalist interface is complete.

I started off using Class Helpers to add library code to VCL objects, for library code. I now find 
myself using them as a design decision, putting minimalist interfaces on my objects, and adding all the 
helper and nicety functions as helper objects. As Marco Cantu 
[points out](http://blog.marcocantu.com/blog/Delphi_past_its_peak.html), it looks like the next version of C# 
will support a similar feature. Personally I feel its another great feature of Delphi giving us a competitive advantage
when developing with Object Pascal.

So what does everybody else think, design feature or abomination ?

Comments (originally on blogger.com)
================================
Anonymous said...

>> Well, Anders Hejlsberg would seem to agree with you that they, or at least the idea of being able to extend a class, is a good thing to expose as part of the language.
>> See http://channel9.msdn.com/Showpost.aspx?postid=114680 and http://mtaulty.com/blog/(zu0cer45karubu55u0cqsa45)/archive/2006/03/20/9271.aspx
>>
>> Specificl look at Extension methods. AKA Class Helpers in Delphi.
    
Anonymous said...

>> Brilliant article

Daniel said...

>> Hi, David!
>> Great article!
>> I personally use class helpers to hide implementation details of some code on the server side of my app, while still publishing classes to the client side. Specially in our SOAP application, when we want our clients to use the same class definition as in the server.
>> Looking forward to seeing your article about REST x SOAP...

TOndrej said...

>> My gut feeling is that what the help says about class helpers is correct, ie. they shouldn't be a part of new design.
>> For various reasons, already written classes become sealed, ie. their interface cannot be changed anymore. An ideally written class would provide all the functionality specified in the design phase, and expose enough information for descendants to extend it as new requirements come. In the real world, however, classes often hide too much or, if you like, do not expose enough. That's where I think class helpers are a big help, they're a way out if you've locked yourself in.
>> Your argument for writing minimal classes and, at the same time, more humane class helpers seems to be based on the fact that minimal classes are easier to test and debug. I agree, but don't you have to test and debug the class helpers, too? Isn't the effort the same or even greater after all? Why not write, test and debug the full class right from the beginning?
>>
>> The above is just my 2c; I haven't used class helpers yet at all. Perhaps I have to play with them a bit and get a better feeling about them first.
>> P.S. A very nice blog so far, cheers!

David Glassborow said...

>> Tondrej I think my point is that testing a class helper is much much easier because it can only affect the public interface, not the internals of the class. If your written the minimalist class properly, its very unlikely the class helper can break it.

TOndrej said...

>> OK, that's an interesting point. I guess I'll take a closer look at those helper beasts ;-)

Anonymous said...

>> The limitations seem (no private field access) seem to prevent a lot of goodies.
>> What probably happens is that if you use type X, all imported units in the interface are searched for helper_for_x, since this is the only way to avoid to scan _all_ units in the entire project for helpers to compile a unit.

Jolyon Smith said...

An old post that needs a sensible comment.

Class Helpers are to be considered "bad" when used in an application because they were never designed for general purpose use, and exist solely to workaround a design problem in the VCL that ONLY existed for the language (or more accurately, the VCL) implementors, not those who implement USING the VCL.

The biggest problem with class helpers, from the p.o.v of using them in your own applications, is the fact that only ONE class helper for a given class may be in scope at any time.

That is, if you have two helpers in scope, only ONE will be recognised by the compiler. You won't get any warnings or even hints about any other helpers that may be hidden.

So you can happily code away with your lovingly crafted helper, then you start using some other unit that contains someone else's helper for the same class and suddenly your helper is no longer "visible".

Of course, since helpers are used - as designed - within the VCL, adding helper classes for VCL classes is most likely to experience this problem.


You may be able to fudge your way out of it by fiddling with the order of your units in the uses list. Or perhaps moving the "help point" of one or other helper up or down the ancestry of the helped class (assuming and hoping that that does not in turn create a conflict with some OTHER helper out there).

If you can't then you are stuck, because you can't even use qualification to forcibly reference the "hidden" helper.

TMyHelper(obj).MyMethod;

Won't compile if TMyHelper is "hidden" by some other helper for the class of obj. In fact, it doesn't work period, because TMyHelper does not exist as a type, so you can't even use this style to aid clarity with bona-fide helpers at all.


There is of course an alternative, which is not only immune from all these problems, but is also actually more flexible/powerful and works even in older versions of Delphi.

That is, to use explicit helper-style sub-classes, the old fashioned way, where you adhere to the rules for helpers (only accessing public methods, not adding instance data etc etc) but use explicit hard-casting to "add" your methods to an instance.

TMyHelper = class(TForm)
procedure MyMethod;
end;


TMyHelper(form).MyMethod;

This is "better" because:

a) it IS explicit. No magic. No wondering where these undocumented methods came from (for the uninitiated, unaware of the existence of your "helper" class is some obscure unit somewhere)

b) it is unbreakable. As long as you stick to the safety rules for implementing the helper itself, nobody else's helper can "hide" yours or interfere with how it works.

c) it is more powerful and more flexible - the "helper" subclass is able to access protected AND public members.


One arguable downside is the need to explicitly cast in order to invoke your helpers functionality.

But that could equally be argued to be a further ADVANTAGE, since it makes it clear that an instance is being treated as something that it strictly isn't.

True, it may involve a little more typing than using a bona-fide helper.

So which you prefer will come down to whether you place more value on saving a few milliseconds of typing time vs potentially hours or even days of refactoring if (more likely "when") you get a "collision" among your helpers.

Anonymous said...

@Jolyon Smith: Nice comment! 

I think it would be worth addressing Jolyon's points in the article so they don't get lost in the comments.