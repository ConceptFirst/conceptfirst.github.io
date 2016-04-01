---
layout: post
title: "Don't change the name of your CRM server"
date: 2014-07-04 12:37:08 +0100
comments: true
categories: CRM
author: David Glassborow
published: true
---
Or rather if you do, be careful what you change the config in the `MSRCRM_CONFIG` table to.

One of our clients recently had an outage where nobody could login to CRM dynamics 2011 for most of the day. All users got the following useful message:

![CrmUnavilable](/files/CrmRecordIsUnavailable.jpg)

Luckily the Windows Event Log recorded:
<!--more-->
``` text
Event code: 3005 
Event message: An unhandled exception has occurred. 
Event time: 04/07/2014 12:25:32 
Event time (UTC): 04/07/2014 11:25:32 
Event ID: c15710915a4141728256c575c3ab2412 
Event sequence: 1015 
Event occurrence: 1014 
Event detail code: 0 
 
Application information: 
    Application domain: /LM/W3SVC/2/ROOT-1-130489361515699691 
    Trust level: Full 
    Application Virtual Path: / 
    Application Path: C:\Program Files\Microsoft Dynamics CRM\CRMWeb\ 
    Machine name: CompanySQL 
 
Process information: 
    Process ID: 904 
    Process name: w3wp.exe 
    Account name: NT AUTHORITY\NETWORK SERVICE 
 
Exception information: 
    Exception type: CrmConfigObjectNotFoundException 
    Exception message: Server ID Was Not Found
   at Microsoft.Crm.ServerLocatorService.GetServerIdFromDatabase()
   at Microsoft.Crm.ServerLocatorService.GetServerId()
   at Microsoft.Crm.ServerLocatorService.GetServerSetting(String settingName)
   at Microsoft.Crm.Etm.EtmServerConfiguration.Initialize()
   at Microsoft.Crm.Etm.RequestGovernor.Initialize()
   at Microsoft.Crm.RunInitializerTracker.TryRun(Type typeOfInitializer, RunInitializerDelegate RunInitializerDelegate)
   at Microsoft.Crm.ApplicationInitializer.Microsoft.Crm.IApplicationInitializer.Initialize()
   at Microsoft.Crm.MainApplication.Initialize(String nameCallerMethod)
   at Microsoft.Crm.MainApplication.Application_OnBeginRequest(Object sender, EventArgs eventArguments)
   at System.Web.HttpApplication.SyncEventExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()
   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean& completedSynchronously)

 
 
Request information: 
    Request URL: http://Companysql:5555/CompanyGroupLtd/XRMServices/2011/Organization.svc?wsdl 
    Request path: /CompanyGroupLtd/XRMServices/2011/Organization.svc 
    User host address: 10.3.0.98 
    User:  
    Is authenticated: False 
    Authentication Type:  
    Thread account name: NT AUTHORITY\NETWORK SERVICE 
 
Thread information: 
    Thread ID: 24 
    Thread account name: NT AUTHORITY\NETWORK SERVICE 
    Is impersonating: True 
    Stack trace:    at Microsoft.Crm.ServerLocatorService.GetServerIdFromDatabase()
   at Microsoft.Crm.ServerLocatorService.GetServerId()
   at Microsoft.Crm.ServerLocatorService.GetServerSetting(String settingName)
   at Microsoft.Crm.Etm.EtmServerConfiguration.Initialize()
   at Microsoft.Crm.Etm.RequestGovernor.Initialize()
   at Microsoft.Crm.RunInitializerTracker.TryRun(Type typeOfInitializer, RunInitializerDelegate RunInitializerDelegate)
   at Microsoft.Crm.ApplicationInitializer.Microsoft.Crm.IApplicationInitializer.Initialize()
   at Microsoft.Crm.MainApplication.Initialize(String nameCallerMethod)
   at Microsoft.Crm.MainApplication.Application_OnBeginRequest(Object sender, EventArgs eventArguments)
   at System.Web.HttpApplication.SyncEventExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()
   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean& completedSynchronously)
 
 
Custom event details: 
```

Various google searches listed other people with issues around machine names (although most seemed to be around getting the async background services running rather the IIS itself failing).  After messing around a bit, a quick `SELECT Name FROM MSCRM_CONFIG.dbo.Server` showed the server name in config was not the same as the machine name (DEV had been put on the end), which prevents CRM from doing anything apparently. Putting in the correct name fixed the problem in two seconds.

Looks like a sys admin got confused between a production and sandpit instance, and updated the wrong config :D

Hopefully this helps somebody else with this particular issue.
