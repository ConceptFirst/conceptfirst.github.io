---
layout: post
title: "Devco Wish List"
date: 2006-10-16 15:31
comments: true
categories: delphi
---
This is my wishlist for Delphi when the new company running it is planning the next version.  My requests are not large things (except maybe the last one), and are in order of priority.

Summary:

- Language construct: return
- . operators on basic types
- Include all source code (midas, dbExpress)
- Ruby
<!--more-->
Return
======

Readable concise code is something we all try to acheive when coding.  I really miss the 'return' statement from C, because it makes code more concise. I'm bored of writing:

    if blah then
    begin
      Result := -1;
      exit;
    end;

I want to be able to write just

    if blah then Return(-1);

Shorter, and the intention of the statement is much more obvious.
I would imagine it would be fairly easy to add to Delphi as a pseudo function (like 'continue' and 'break').

Dot Opeators
===========

I've been doing a fair amount of Ruby recently, as well as some C#. Having the dot operator available on all basic types is lovely, and makes code much more readable. I'd much prefer

    address.length

over

    length(address)

Less visual clutter, much more OO.
Even if behind the scenes is just syntactic sugar to call the length procedure, that would be a huge win for the readability of Object Pascal in these Object Orientated times.

Source Code
==========

At Concept First we currently use the following third party libraries:

- Devexpress: Quantim Grid, Quantum Bars
- TChart charting component
- CoreLabs dbExpress driver for SQL Server

We will *only* buy a component if it comes with full source code.
Why ?

1. Fixing bugs when we find them
2. Adding new features
3. Tracking their changes under source control

We've made changes to all of the components we use, and I have all their source code under Subversion, so I can see what they have changed and see what possible impact it could have on my code.

One of the great strengths of Delphi has always been that the VCL comes with full sources.  The two exceptions are the TClientDataset (midaslib.pas) and the dbExpress drivers.  Its very annoying not to be able to debug into their code.  I know Midas is in C++, but I have the full BDS with C++ support so that is not an issue. I use TClientDataset all over the place, and there are a few easy extensions that could make life much easier.

Ruby
====

As mentioned before, i've been playing around with Ruby and Ruby on Rails recently, and the first thing I had to do with is knock up a quick syntax highlighting editor using the SynEdit control. Having Ruby (and in an ideal world Javascript) in Delphi, with code complete, would be great, something I would be happy to pay for). Web development seems to be the way of the future, and having a nice IDE supporting Ruby could be a big win for Delphi / Devco.

Summary
=======

I don't know if my use of Delphi is similar to the majority of other users, but my priorities from it are:

- Fast to develop in
- Looks nice (generally easy thanks to DevExpress)
- Source code so I don't get held up by bugs
- Reliable and fast IDE
- Small self contained EXEs, without frameworks to install.

I use delphi for Win32 client applications.  I don't use it for web applications. I now use either Ruby on Rails ( my personal choice ) or Cold Fusion ( trusted in Enterprise environments ).

I'm not interested in:

- Delphi.net
- 64 Bit support
- Mobile development (be nice if Delphi supported, but such a small % of our work I'd be happy enough to use Visual Studio).

Anyway if I could have the requested changes made by the end of next week, that would be great DevCo ;-)

Pretty Please ?