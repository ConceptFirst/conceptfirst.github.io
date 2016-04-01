---
layout: post
title: "Upgrading OS X to Leopard"
date: 2007-11-02 16:05
comments: true
categories: mac
author: David Glassborow
---
Having just returned from two holidays: Colorado with a motorbike (lovely people, stunning scenery) and Firenze with my lovely girlfriend (lovely people, stunning architecture and art) I decided to update my OS X partition to the new shiny leopard. Here are a couple of notes of how I got on, which is hopefully useful to anyone else doing the same.
<!--more-->
# Leopard


Initially I chucked the disk in and just did an install, this installed the OS over the previous one. Everything seemed to work fine, except I had installed Java 1.6 beta from Apple, and this didn't work in the new OS (see google for rants about 1.6 JVM not being supported). I needed a working Java for programs such as [FreeMind](http://freemind.sourceforge.net/). I tried to sort it out by changing symlinks in the system folders, uninstalling the beta, but basically just broke everything. I decided to reinstall the whole thing, which requires you to notice the 'customise' button on the installer, allowing you to request it clear the disk first (but usefully also allows you to not install various things like printer device drivers which saves you gigs of space !).

Having a new install, things definitely felt faster. I also booted into bootcamp, put in the 10.5 disk which installed the latest windows drivers for everything.

I got most of my development software sorted in an hour or so. The new OS seems to have lots of development tools built in (I installed the XCode package from the install disk as well), like subversion, ruby and even ruby on rails (saves on things to install via [MacPorts](http://www.macports.org/))

When you buy a Mac, it comes with the iLife software (iPhoto, iDVD and all that) but an OS upgrade doesn't contain them, so I reinstalled iPhoto from my 10.4 disks which worked fine.

# Parallels

To get Parallels working I had a look on google and people recommended running the newly released Beta 5540 (your license will work fine with this, no need for beta license) - find it [here](http://www.parallels.com/products/desktop/beta). I installed it, it detected my bootcamp partition, but trying to run it caused an immediate OS X crash. I restarted the machine any everything was fine. Or so I thought.

Next time I logged into windows I got an error immediately after entering my log in details: **A problem is preventing Windows from accurately checking the license for this computer. Error code: 0x80070002**, followed by an immediate logout. I tried both Parallels and Bootcamp and the same issue on both ! A Microsoft [kb](http://support.microsoft.com/kb/310794) describes this as related to an issue in Windows paranoid licensing checks. Other similar issues seemed related the use of Volume Licensing keys (I use our company's VL keys for my windows machines) - I tried the suggested fixes but no help. After lots of messing around, I found a [post](http://www.jsifaq.com/SF/Tips/Tip.aspx?id=8521) on the interweb that suggested it was an issue with some files in system32, oembios.*. Looking at these 3 files, they had change dates in the last 24 hours. A copy of the files from another XP SP2 installation fixed the issue (via Safemode and a USB key) , returning change dates back to 2004, got everything working perfectly again.

No idea what broke these files, whether it was Parallels, Bootcamp drivers or something else ?

Another oddity, to fix windows to run in both Parallels and Bootcamp, I had to apply the fix once in each mode (which is really weird - somehow related to the use of different hardware configurations to allow parallels to do its magic - anybody understand how this works ??)

# Misc

The only other issue I have come across was that once connected to a VPN (to a windows 2000 server), DNS lookups on my Mac were really slow (like 20s). Looking on the net, there were suggestions that the resolver stack had changed slightly in the new OS, and may be working badly with old routers / dns servers in some way. Adding my local DNS server to the VPN's DNS settings (under Advanced in Network system preferences) seems to have done the trick though.

Now having everything working fine and dandy, there's no excuse for putting off actual useful work, how disappointing ;-)