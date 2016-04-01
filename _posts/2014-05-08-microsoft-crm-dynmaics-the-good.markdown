---
layout: post
title: "Microsoft CRM Dynmaics: the good, the bad and the massive"
date: 2014-05-08 09:03:27 +0100
comments: true
categories: CRM
author: David Glassborow
published: true
---
I've been working with Microsoft CRM dynamics for about three years now, with a couple of different clients.  Both clients use CRM is quite different ways, and having varing levels of customisation and integration. Here is a shortish list of my experiences with it, and thoughts around what to consider when choosing and implementing it.
<!--more-->

Here is a diagram of the key entities in standard CRM for reference:
![CrmEntityDiagram](/files/CrmStandardModel.png)


Positive
--------

- Rich filtering and user defined views of records makes it easy to define what to work on
- Creating new related records from the search is nice
- Templates (e.g. campaign)
- Good consistent keyboard shortcuts
- Drill down charts built in
- Can Connect any entity in the system to anything else

Negative 
--------

- Quiet a learning curve to get comformtable with the system
- Expensive contractors if you need support
- Not clear to see relationships, a view of a single entity can only show 1 level of related data 
- Lots to learn, doesn’t manage processes, very much data orientated
- Don’t have an english explanation (e.g. on service), need to jump around to fields to understand what it is (the narrative)
- All due dates as specific rather than SLAs from times. You need to write plugins to do SLA type code.
- Fragile: AD integration, Exchange, Sharepoint, etc.  Each on their own is complicated and scary, together they are very fragile !

The massive
-----------

- The database is very large.  All primary keys are 128 bit guids, and there are lots of foreign keys leading to very wide tables.
- The flexible nature leads to lots of indexes to get reasonable performance, meaning your database will get big, quickly, especially on Activity entities.
- You will need big faster hardware to make it run reasonably.

Best pracitises when customising
--------------------------------

- Modelling your business up front is a good idea, but before making any changes, live with CRM for a couple of months before customising it.  Once its changed, you've diverged from standard CRM and its gets harder to support.
- Rename the existing entities to better match your terminology. Cases might be better named Tickets for example.
- If you do customise, repurpose existing entities and their functionality, they have special abilities that custom entities can't have.
- For processes, rather than change fields on an entity, create a new one to better model what actually happened (eg. if you try to call back a customer and can't get through, rather than just resetting the due date on the telephone call, make a new one and mark the old as failed to get through ). You will then better be able to report on what actually happened. Dialogs can be written to make this straight forward.
- If you have complex business processes, consider writing custom friend ends in standard web server code, and then using the CRM SDK behind the scenes to store the data in CRM. This way you can fully control the end experience for the user, and guarentee the data quality that ends up in CRM, making sure all records are correctly linked, etc.

- links:
  - http://msdn.microsoft.com/en-us/library/gg509027.aspx
  - http://stackoverflow.com/questions/190839/how-is-your-experience-with-microsoft-dynamics-crm
  - http://msdynamicscrmblog.wordpress.com/2014/01/15/best-practices-for-reports-in-dynamics-crm-2013/
  - http://blogs.msdn.com/b/crm/archive/2010/01/15/microsoft-dynamics-crm-workflow-authoring-best-practices.aspx
  - http://blogs.msdn.com/b/lezamax/archive/2008/04/02/plug-in-or-workflow.aspx
  - http://dynamicsuniversity.com/blog/crm-implementation-best-practices
