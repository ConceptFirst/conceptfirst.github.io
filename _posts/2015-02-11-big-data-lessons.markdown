---
layout: post
title: "Big data challenges"
date: 2015-02-11 12:01:53 +0100
comments: true
categories: Cloud Data
---

Following on from my article about working with Azure: [Azure Lessons](/blog/2014/10/15/azure-lessons/), here are some of the lessons I've learnt recently working with _Big Data_ and cloud computing.

![CloudComputingImage](http://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Cloud_computing.svg/400px-Cloud_computing.svg.png)

<!--more-->

We've been working on various projects for clients (I can't give too many details for reasons of commercial confidentality), with large amounts of data.  As I expect is the same for a lot of developers these days, we are all getting involved in Big Data.  One of our projects has involved Telemetry data from Scada systems, and in this instance the challenge has been providing real-time views of lots of fast  changing data.  In another project around Health Care, we've been writing systems looking for patterns in data, where the data size is into the hundreds of millions.

So in order of importance:

1. You'll spend 10 times longer that you plan on cleaning your data.
2. Confidentially vs Cloud Computing
3. Normalisation for the win


Cleaning data
-------------

The issue crops up again and again in general software development, Machine Learning, Data Analysis, and science in general. Getting data cleaned up from the noisy, messy real world, is complicated, time consuming and very frustrating.

Really nothing has changed, it's just when you’re dealing with billions of records the impact becomes more and more profound. The choices of how you categories data in those uncertain situations can significantly impact your analysis, your stats and your results.  Its like the [law of large numbers](https://en.wikipedia.org/wiki/Law_of_large_numbers), unlikely problems quickly become significant at scale.

At the moment, I don't have any good answers for this, apart from being aware up front of the issue, and the time commitment that needs to be made. In the long run I'm hoping as data collection gets better (i.e. more apps, less Excel spreadsheets), the issue will become more manageable.


Confidentiality
---------------

The advantages of cloud computing are many including:

- On demand provision, only paying for what you need
- Reduction of spend on maintenance and support of your own hardware
- Economies of scale so providers can keep prices low

We've been involved in various cloud and data centre projects ( Amazon Web Services, Azure, data centres with Sky Television, CRM hosting with the [now defunct 2e2](http://www.channelregister.co.uk/2014/02/20/what_we_learned_from_2e2_collapse/) ). One of the big challenges that comes up is confidentiality of data. Some of this is the difference in location (indeed some of the Sky data was intentionally stored abroad due to more relaxed laws), and some of it is around personal identifiable data. Health care in particularly worries about this, and rightfully so. The NHS doesn't allow any data to leave it's N3 secured network. 2E2 had a UK data centre so that companies could keep data under UK law.

Without the ability to easily move between data centres, we are in danger of losing the advantages of the cloud, especially around on demand provision.

Microsoft Research is looking at hardened virtual provisioning through projects like [Haven](http://research.microsoft.com/apps/pubs/default.aspx?id=223450), but more interesting to us at the moment is the use of [Homomorphic Encryption](https://en.wikipedia.org/wiki/Homomorphic_encryption). This is the use of certain types of encryption that allow the records you store with your cloud provider to be completely secure and opaque to them, but you can still use their machines to search, filter and calculate on the data. It's an excited area, with new reaseach being published all the time.  Google already have a [prototype](https://github.com/google/encrypted-bigquery-client) for their Big Query cloud offering.



Normalisation for the Win
-------------------------

For us, normalisation in data design has been a huge win. As our databases become larger and larger, we are loathed to move away from Relational models to less structured data like key-value stores and graph databases. it's not that these systems aren't great at scale, it's just you lose a lot of flexible ad-hoc querying as soon as you get that big. We've had great success at stalling the move to NoSql stores by ruthlessly normalising our database designs.

By taking database designs and introducing entities that don’t necessarily represent business concepts but do radically normalise the data model, we've seen reductions in size by an order of magnitude, and this has often given equally dramatic improvements in performance.
