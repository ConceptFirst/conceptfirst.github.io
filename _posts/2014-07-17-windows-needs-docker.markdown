---
layout: post
title: "Windows needs docker"
date: 2014-07-17 09:22:04 +0100
comments: true
categories: Infrastructure
published: true
---

I've been using [Docker](https://www.docker.com) a lot recently when setting up our Linux main server. If you've never used it is, I highly recommend it. It is a way of compartmentising your software. You run software in its own docker containers, they share the same machine, but are isolated from each other, can have different versions of common dependancies (like dlls).

Its like have lots of VMs running, without the massive overhead of running virtual machines.

It's built on Linux kernel features that allow processes to be isolated from each other (having their own network stack, etc) and union file systems that isolate the file systems efficiently from each other.

[https://www.docker.com/whatisdocker/](https://www.docker.com/whatisdocker/)

**Microsoft Windows really needs this**. Every client I've worked with ends up having loads of Windows servers, all running at 1% utilisation, just so everything is isolated, and that one version of SQL Server won't break another version, or that the latest version of the C++ runtime breaks a product you bought 3 years ago ...

Unfortunately the Win32 API doesn't have the features to implement it presently, and the [Jobs API](http://msdn.microsoft.com/en-gb/library/windows/desktop/ms684161.aspx) that looked like it could be the way to go, seems recently to have been depreciated and not fully supported in each version of the OS (just search stack overflow for all the problems).

Lets hope Microsoft feel the pressure from Linux on this, but they probably too busy relaunching Bing or rebranding _Windows Phone 7.5 Embedded Mobile CE_ to notice.