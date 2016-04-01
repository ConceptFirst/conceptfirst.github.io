---
layout: post
title: "Professional Development on a MacBook Pro"
date: 2007-07-12 16:53
comments: true
categories: mac
author: David Glassborow
---
Like a number of people in the Delphi Community ( [Steve Trefethen](http://www.stevetrefethen.com/blog/RunningWindowsVistaOnAMacBookPro.aspx), [Dan Miser](http://www.distribucon.com/blog/PermaLink,guid,0966f2d8-377b-4223-99b0-b4feff53cd60.aspx) ), and the development community as a whole, I now do all my development on a MacBook Pro. I changed to an Apple machine six months ago, for a number of reasons:

- I needed a new laptop, and the MacBook Pro hardware is so goddamn thin, light, and good looking.
- I am becoming increasingly disillusioned by Windows, especially the new [DRM](http://www.forbes.com/security/2007/02/10/microsoft-vista-drm-tech-security-cz_bs_0212vista.html) stuff.
- I fancied trying out OSX, a change is as good as a rest and all that.
- Bootcamp and virtualisation allow me to use Windows XP on an Apple laptop.
- The web is freeing us from being locked into particular Operating Systems.

As a professional developer, most of my clients run Windows, and most of my native development is done using Visual Studio 2005 or Delphi 2006, connecting to SQL Server or Oracle backends. I boot my laptop into Windows to do this work, or use Parallels to run it with Mac OSX (when I got my MacBook Pro I got it with 3G of RAM so Windows runs pretty fast inside OSX). Increasingly though I am doing web development, which means I can do much more work inside just OSX.

The more I have used OSX, the more I prefer it to Windows, so I have put together this list of tools and hints for doing professional development on OSX:
<!--more-->
Using Bootcamp
--------------

- Steve has got an excellent [list](http://www.stevetrefethen.com/blog/WindowsKeyboardShortcutsOnAMacBookPro.aspx) of the keyboard mapping for Windows
- [Parallels](http://www.parallels.com/products/desktop/) allows runs Windows (from a bootcamp partition) in OSX
- As does [VMWare](http://www.vmware.com/products/desktop/fusion.html)

Using OSX
---------

One of the things there first confused me using OSX is the link between a visual Window and a running program. Having used Windows for the best part of 15 years, I had the strong mental link between having a open window and having a program running. OSX is much more like the systray in a way. In most instances, a program carries on running even if all its windows are shut. At first this seems odd, but now I am actually used to Mail and iCal running in the background, collecting mail and showing me reminders, without having windows cluttering up the place or being minimised. Also the dock changes icons depending on status of the program, so I can see that new mail is waiting, without requiring an open window to tell me.

I guess it is the unix heritage, but OSX seems much happier having loads of programs running a the same time, than Windows would (or maybe this laptop has just got too much memory).

Another change from the Windows way of thinking is about installation of software. In OSX an application is a directory with a name of BlahBlah.app. It contains all that is necessary to run. So drag and drop to install software, move things around as desired, and delete it when no longer wanted. Only software that needs to make system changes needs to have install scripts.

You need to install [Quicksilver](http://quicksilver.blacktree.com/) for launches programs, and more advanced voodoo. Have a look at some of the screen casts at [The Apply Blog](http://feeds.feedburner.com/TheAppleBlogScreencasts), a good beginner one is [here](http://theappleblog.com/2007/06/29/screencast-quicksilver-for-beginners/). You won't believe for a powerful bit of software it is.

Another thing worth getting your head around is this idea of OSX services. These are simple 'services' that are provided to all programs running, accessible of the programs menu. While there are some useful ones built in, there really come into the own where you start changing them using [Service Scrubber](http://www.manytricks.com/servicescrubber/) and [This Service](http://wafflesoftware.net/thisservice/). See some examples from [John Gruber](http://daringfireball.net/2007/04/google_lucky_thisservice) about writing your own scripts and making them available to all apps (although I'd recommend using Ruby over Perl ;-).

Web Development
---------------

It goes without saying that you should be using Firefox with Firebug for web development. Day to day browsing I use [Camino](http://www.caminobrowser.org/) which is the firefox engine inside a more OSX integrated and looking program.

- [Textmate](http://macromates.com/) is a great editor, as most people know, but if you are doing any JavaScript development make sure you get the [JS Tools](http://macromates.com/blog/2007/javascript-tools/) bundle. Having your script 'lint'ed everything you save is a great productivity improver. Also get the [GetBundle](http://projects.validcode.net/getbundle) bundle to make it easy to manage extensions and find new ones. Blog writing is easy with the built in [markdown](http://daringfireball.net/projects/markdown/) support.
- [Eclipse](http://www.eclipse.org/) (especially with the new CodeGear betas running inside Eclipse ) has plugins to do pretty much everything (although I still use Textmate most of the time).
- Anybody know of a Fiddler equivalent for OSX ?

Subversion
----------

Does anybody use anything else anymore ?
I use the tigris plugin [scplugin](http://scplugin.tigris.org/) to have subversion integration with the finder. It is not quite as good as tortoise. There is also [Svnx](http://www.lachoseinteractive.net/en/community/subversion/svnx/features/) which is ok, but I don't find the UI all that intuitive.

Database Access
---------------

For connecting to Oracle, I use the free [SQL Developer](http://www.oracle.com/technology/products/database/sql_developer/index.html) which has a native OSX version. Most of the open source databases have native clients (e.g. Postgres), but otherwise I use [Aqua Studio](http://www.aquafold.com/downloads.html) v4.7 which is free. One of the nice things is most of the tools are Java based, so if you can find a JDBC package for your database, chuck it in /Library/Java/Extensions and then all the Java apps on your machine have connectivity to it (I have found ones for SQL Server, Oracle, MySql and Postgres).


Other Languages / Database Engines
----------------------------------

- Anything available in the Open-source world, if not explicitly released for OSX, is normally available on [DarwinPorts](http://darwinports.com) or [Fink](http://finkproject.org), projects to make linux/unix software compilable on OSX (which is a unix variant behind the scenes), and easily installable handling all the dependancies etc.

---

Are there any useful development tools or hints I have missed ? Let me know and I'll try and keep a development bias list on this page.

And if your still using boring old Windows, come and join the revolution !

Comments (on old platform)
--------------------------

Steve Trefethen said ...

> Great post. It's good to have  growing list of bloggers using this setup for Development to share information like this.  Thanks and subscribed!

Fernando Madruga said ...

> Nice to know that using OSX can be a viable solution now that MS is screwing up big time on their OSes! Heck, my father-in-law, which is a "regular" computer user, just had his notebook re-formated and installed Windows XP to *upgrade* his brand new Vista! It suits him well, as I had warned him against Vista but then he bought a new laptop with Vista on it and after a couple months of suffering decided it was just about time to start working again! :)

Andre Voget said ...

> We also develop our software programs on Mac OS X using Parallels Desktop. It's great to make backup images of the whole development setup.

Jose Crespo said ...

> Me too.
I have a MacBook 2Gb. I don't use BootCamp. With Parallels I can run Delphi, VisualStudio, SQLServer,Firebird. My VM is congigured with 700MB. Untin my MacBook, I had two computers. Always a mac for enjoy and photos (since 1986 ... not the same of course, but I have all of them) and a PC for development in Delphi and VisualStudio.

Rob Uttley said ...

> My situation/setup is similar to Jose Crespo's (above).... 2Gb MacBook Pro (last summer's model, unfortunately, so it's Core Duo not Core 2 Duo).

> When I'm in the office it's plugged into an apple keyboard, mouse and 21" Cinema display, the laptop on a griffin stand and the laptop screen being a good place to leave Mail.app and browser windows open whilst I'm working on the big screen.

> I use Parallels (v2, build 3214) with a 15Gb virtual machine that include Delphi 7, SQL Server Express, Interbase, Office and chunks of VS2005, all running under XP Pro SP2. The Parallels system has about 700Mb of ram assigned to it, and configured so that it appears on my network as a machine in it's own right, alongside the Mac and various test machines (both real and virtual). I don't make use of coherence etc - I find it less confusing when developing to have the PC window taking almost all of the display space anyway.

> The performance is great, and the convenience of bring able to back-up an entirely 'bootable' copy of my dev box every night is awesome (I have a little piece of applescript/automator that just pushes the vm harddrive over to a drive on the main file server). Given the price of diskspace, and the speed of networks, not only is this kind of backup perfectly feasible but once you start using it you quickly have a handful of different virtual machines, and you put the images on the hard drive that you're going to need for the next couple of days' work.... it's a really nice way to have everything to hand without having one huge monolithic drive with absolutely everything installed (and all the attendent problems that can bring).

> Talking of convenience, the MacBook Pro is a dream. Okay, it's not small thanks to the 17" screen, but it's slim and light, and when I get on a train and start working it just goes and goes and goes - I get into the two-and-a-half-hours and still running stage frequently without making any real sacrifices on the battery front.

> I'm not a huge fan of the keyboard, and having to ctrl-click on the trackpad for a right-click (when I haven't got a mouse plugged in) is a pain. Once you get used to OS X I find it a nicer place to 'play' in - my fiance is getting used to OS X over Windows XP and the next box I buy my mum will run Tiger/Leopard, not XP/Vista. For most of the time, it really does just work. :-)

> Best of all is the reaction you get when you go out to a client's to demo something and they see you break out a Mac, then rapidly switch into a PC in a Window... :-)

Followup from 2011
------------------

Revisiting this page when moving it to another blog engine, I'd suggest:

- VMWare fusion for virtualisation
- Navigate lite database tools (free and on the AppStore)
- Versions for Subversion
- GitX for git
- Homebrew for installing software
- [HFSExplorer](http://hem.bredband.net/catacombae/hfsx.html) to access files when inside bootcamp
- [CoRD](http://cord.sourceforge.net/) for remote desktop into windows machines

