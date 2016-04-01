---
layout: post
title: "Seriously it depends!"
date: 2014-07-10 09:19:55 +0100
comments: true
categories: Consulting
author: David Glassborow
published: true
---
I recently watched the discussions between Kent Beck, Martin Fowler and DHH, on [Is TDD dead?](http://martinfowler.com/articles/is-tdd-dead/).

The discussions are fine, but the problem is one that all analysts are familar with, _It Depends_. DHH writes relatively simple end project management SAAS tool, Fowler works in much more complex business environments, and Kent deals with infrastructure at Google.  Is it really surprising that they have different opinions on how and when to apply to TDD, when their problem domains are so differernt ?

In most of my code, testing hasn't been helpful, but in 2 situations its been an absolutely life saver. One is testing third party web services, one a CRM system, another a ERP, that were insulating by a SOAP/HTTP end-point for other systems to use.  The tests allowed me to capture third party issues, but more importantly allowed aggressive refactoring without fear of breaking things.

The second was for an overtimes claims systems, with very complex payroll rules around which claims were valid, how much they were paid, etc. The rules had very complex interactions, and by testing them we were able to find inconsistency in their business rules, and again to support future changes without breaking existing systems.

Other development where I've done testing, it hasn't helped, or it has been a hinderance. The value of experience is of course that ability to answer _On What_ it depends.

Nobody expects doctors or engineers to give the same advice in every situation, so why does that have to be one set of rules for testing in software development ....
