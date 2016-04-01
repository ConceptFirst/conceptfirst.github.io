---
layout: post
title: "Moved to typo"
date: 2006-10-16 11:14
comments: true
categories: web
author: David Glassborow
---
What
====

I've moved my blog away from Blogger.com and on to a [Typo][] installation hosted ourselves. Typo is a weblog application that runs on top of [Ruby On Rails][], the latest poster child of the open source community. I chose a rails based blog because I've been doing work with rails recently, I understand it, and I really like it (I'm half way through writing up an entry about why I like it).

Why
===

The main reason is that blogger feed does not include comments people make. I personally read most blogs in an aggregator, and without comments being included, its only one half of the conversation.

For the last year we have been working on a product for a client that uses [Queuing Theory][] to model how servers operate under load, an area known as 'Capacity Management'. Performance agents log ongoing behaviour on the server, and then the results are plugged into various mathematical formulae that show how the server will work if your email doubles, your websites have 10 times as much load, etc.

Here at Concept First we have a data centre hosted server that handles email, ftp, and various client's websites.  In the spirit of 'dog-fooding', I've been running monitoring software on our hosted server, and building models of its spare capacity.
<!--more-->
The results are: we have stupid amounts of spare capacity. The server is a 1U rack mounted server from Dell, 1G of RAM, mirrored RAID disks, a single 2Ghz processor.  A fairly low spec machine these days, we bought it about 3 years ago.  And basically it never does anything. I've never seen the CPU loads rise about 5%, same for disk utilisation.  Modern hardware is so fast, that a few web requests and a bit of email are not not giving it much of a workout.

For that reason, I'm happy to run an interpreted language framework for this blog, because we really do have CPU cycles to waste, and I don't have time to waste.  Having a Rails app running on my server full time will also allow me to understand if it's stable under Windows.

How
===

Style
-----

Typo is easy to install if you've worked with Rails, its just a load of files in a directory. You can choose from 2 built in themes or download lots of others. I've taken one of the built in ones and just changed it to make use of the full screen.  

I *hate* fixed width websites.  What is the point of my lovely 1920 wide screen laptop if the site is only 500 pixels wide !!  Adjusting to the display has always been a key strength of HTML.  Too many people are still designing for the web as though it was a piece of paper ! 

However the move away from fixed width has caused a small bug to display in IE 6, when using the search box in the top right hand corner.  There is flickering as the AJAX call is done.  However the issue does not occur in IE 7 or Firefox so it is no doubt one of the boatload of IE 6 rendering bugs, so i'm not going to pursuit it. Life is too short.

Database
--------

Typo supports just about every database, but I've just left it running on a simple [SQLite][] database. Typo caches everything so i don't really need the hassle of putting it in a real RDBMS.  The server is already running SQL Server, MySQL and Oracle XE. Maintaining what apps use what databases, where, is a bit of a headache. A file based database is just easier to manage if you can get away with it.

Webserver
----------

Our server is running, or has run in the past, various different websites running on lots of different technologies: ASP, Websnap, Coldfusion, Zope, Php, Perl. To manage all this, we use Apache 2 running on Windows Server 2000. Apache has been good to us.  Its very flexible, well documented, secure, and scalable. It is our Internet facing webserver. It handles SSL, compression (via mod_deflate) and virtual hosting.

To connect our hosted sites up to the Apache 'gateway' we've tried various things. We've tried Apache modules, ISAPI, [FastCGI][], SCGI, mod_php.

Apache modules / ISAPI: Nice and fast, but too tightly bound.  When Apache versions change a recompile is required.  Restart the server and you lose server state, like current sessions. Bugs can jeopardise the server stability.

FastCGI: Works well, we have various websnap sites running over FastCGI. However the protocol is complex, binary, and the whole FastCGI protocol is not actively developed any longer.

SCGI: A simpler version of FastCGI, I've run a couple of Rails sites on SCGI.  The protocol is easier to understand, but its another set of config to learn, and not all technologies support SCGI.

With this in mind, we now use simple HTTP proxing.  Each different application runs its own webserver on an internal port number, the firewall preventing any access to the outside world.  Apache then uses its mod_proxy settings to pass the request to the applications webserver, before passing it back to the web browser.

Advantages:
- Debugging is simple. Just fire up a copy of [Fiddler][].
- All applications support SSL, Apache handles it.
- All applications support compression, Apache handles it.
- All application logged in same format, I can use the same tools.
- Apache can use its redirect rules to enforce my rules (e.g. admin in Typo must be secure).
- Upgrading any individual application has no effect on the others, everything is loosly coupled.
- Most importantly: One set of syntax for me to remember.

It all works beautifully.  It's happily proxing to Rails, to web services exposed in Indy components. It's fast, and it 'Just Works', not often you get to say that in the world of computing ...

[FastCGI]: http://www.fastcgi.com/
[Fiddler]: http://www.fiddlertool.com/fiddler/
[Queuing Theory]: http://en.wikipedia.org/wiki/Queuing_theory
[Ruby On Rails]: http://www.rubyonrails.org/
[SQLite]: http://en.wikipedia.org/wiki/SQLlite
[Typo]: http://typosphere.org
