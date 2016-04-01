---
layout: post
title: "What happens when you squeeze a graph model into a relational database"
date: 2014-07-07 12:41:02 +0100
comments: true
categories: CRM
author: David Glassborow
published: true
---

Microsoft CRM Dynamics is becoming a popular solution of CRM, case management, etc. It has reasonably complex data model, with support for Activities (e.g. Email, Phone calls) which are things the users need to do (email somebody, go to an appointment, etc.). These activities can be related to pretty much anything in the system, which makes sense, the Activities are the _verbs_ of the system, with the other tables being the _Nouns_.

![CrmEntityDiagram](/files/CrmStandardModel.png)
<!--more-->

Unfortunalty CRM runs on a SQL Server, and in particular takes certain design decisions (around the use of GUIDs), that leads to the following picture. The ActivityPointerBase is the base table for holding activities in one the customer systems I support.

The table itself is 8Gb, which is big but understandable.  The indexes are **23Gb** however !!  The database is growing very quickly, and the largest culprit by far is these indexes. CRM Dynamics creates indexes to handle every possible link between entities in the system, but in this instance (with relatively little customisation) we are already up to 51 indexes on that table, and response time for the users is getting progressively worse ...

Maybe they should of used a [Graph database](http://en.wikipedia.org/wiki/Graph_database) like [Neo4J](http://neo4j.com) which is really a better fix for highly related data like CRM.  You also get the feeling that the Microsoft designers of the database didn't have much real world experience ...

![Indexes](/files/CrmActivityIndex.png)