---
layout: post
title: "Azure lessons"
date: 2014-10-15 15:01:53 +0100
comments: true
categories: Database Infrastructure Cloud
---

I've spent a frustrating week trying to get a legacy app running against SQL Server into the Microsoft Azure cloud.

Here are the things I wish I knew before I started:
<!--more-->

1. Azure SQL Server is not the same as normal SQL Server, it doesn't work the same
2. Azure Virtual Machines cannot host normal VPNs
3. The two different Azure dashboards do subtly different things


Azure SQL Server
----------------

Summary:

- Uploading an existing database is not straight forward
- SQL Server Management Studio (SSMS) 2012 can connect to Azure, but you lose a lot of the standard functionality (e.g. it cannot setup users, just gives you a script that is wrong )
- You can only connect using SSMS as a administrator user, you cannot connect as a normal user at all
- Microsoft Access doesn't work with Azure databases at all (and it never will)
- It seemed to regularly drop connections that normal SQL Server wouldn't (I guess a consequence of a shared box), even when I was only connected 2 or 3 times

I needed to move a SQL Server 2012 database into the 'cloud', i.e. on to Azure. I stupidly assumed this would be easy, it wasn't !!.

After installed Management Studio 2012, there is a nice 'Task' to move the database to azure. Of course it didn't work

Problems that will break import to azure include:

- Orphaned user accounts - use `EXEC sp_change_users_login 'Report'` to list and `EXEC sp_change_users_login 'Auto_Fix', 'user'` to fix
- Fill factors on indexes (never found a solution for this, [this](http://stackoverflow.com/questions/16542191/sql-server-change-fill-factor-value-for-all-indexes-by-tsql) didn't work for me)
- Tables without a clustered index
- Extended properties (like created by database diagrams, see [stackoverflow](http://stackoverflow.com/a/17853448/131701) note my comments)

You can check if your database is okay to put on azure by using a command line tool installed with SQL Server 2012 (all editions) - see [documentation](http://msdn.microsoft.com/en-us/library/hh550080.aspx) and use the action:export option.  This will produce the same list of errors that the 'Deploy Database to SQL Azure' tool in Management Studio.
 
This and a few other approachs are listed [here](https://social.technet.microsoft.com/Forums/en-US/cef8d994-1378-4403-870d-c851d324508c/how-to-importexport-sql-azure-database-from-one-dabase-server-to-another-programmetically?forum=ssdsgetstarted)

I had no success with these (and didn't explore more complex ones like [this](http://blogs.msdn.com/b/ssdt/archive/2012/04/19/migrating-a-database-to-sql-azure-using-ssdt.aspx))

I scripted the database import in the end, which took a while, but in the end Azure SQL Server just didn't work for us for the reasons above, I ended up setting up a virtual machine and installing SQL Server Express (the database was only small so express was fine).


Azure Virtual Machines
----------------------

After frustration of trying to get a simple PPTP VPN setup, turns out Azure doesn't support VPN protocols through its firewalls. Apparently there is some custom software called 'Azure connect' for this, but I need a Linux box to connect to my VM, so I'm going the OpenVPN route.


Azure Dashboards
----------------

There is the old dashboard, and the new portal which is in beta:

- [https://manage.windowsazure.com](https://manage.windowsazure.com)
- [https://portal.azure.com](https://portal.azure.com)

The new port is nicer to use, but there are subtle differences in how the provisions machines. For example a new VM will end up with differently configured end points depending on which route you follow, and there are somethings the new portal cannot currently do (like configure Azure SQL Server backups).

In the end I used the old dashboard to change things, and used the new portal as read only (until its out of beta).

Anyway hope this information saves somebody else some hair :D 







