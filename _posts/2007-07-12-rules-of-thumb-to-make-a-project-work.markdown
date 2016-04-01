---
layout: post
title: "Rules of Thumb to Make a Project Work"
date: 2007-07-12 15:53
comments: true
categories: consulting
author: David Glassborow
---
I am currently coming to the end of a large project for one of our clients, where I have been acting in the Business Analyst and Technical Lead roles. It has been a fun and successful project, and I wanted to pass along some of the lessons I've learnt (again) about how to make Technical Analysis (and the project as a whole) successful (and also make a checklist for next time around ;-).

It must be remembered that IT solutions (and really any business change) are all about two things: Incentives and Trade-offs.
<!--more-->
Incentives
----------

Incentives are important because ultimately people are lazy, and this is A Good Thing. We all have way too many things to do in our lives, both personal and professional, and therefore being lazy is a very successful evolutionary adaptation on the part of Homo Sapiens. The body only bothers to grow stronger muscles when we actually need them, rather than paying the cost of having them all the time. The same approach can be seen in our behaviour.

To make people want to use your new approach / program / business process, you need to make it worth their while. This seems obvious but I see it being forgotten time and again. Sometimes the incentive is fear of being fired, but ideally you want to make your user's lives easier and more efficient. If you can't incentivise them to change their behaviour, they won't.

Trade-offs
----------

Any new system involves trade-offs. If it was a simple no brainer, it would have been done ages ago. Management often want better visibly of information (and normally control as well), but they need to be made to understand that this will have added costs, whether that is in increased paperwork, administration, or work enjoyment for the staff. Often people assume they get increased efficiencies (or whatever) for free, but there is always a downside. Not that that is a problem, but it needs to be understood and communicated (it goes into the areas of risk management). Communicating this as quickly as possibly, and ideally suggesting different cost/benefit scenarios, makes sponsors think more about why they are asking for things, and better controls their expectations.

---

From these two overriding principles, we then have a randomly ordered list of my current best practises.

Technical Analysis Best Practise
--------------------------------

1. Always sit with the users
2. It's all about incentive
3. Mastery of language is important
4. Its easier if you don't care
5. Avoid the middle men
6. Flexibly and Power => Complex and slow
7. Easy to think != Easy to do. Details matter

The above points in more detail:


1 - Always sit with the users

Sounds obvious, but on every project I see it being ignored. 30 minutes of sitting with the actual users you are providing a solution for, will give you better and more accurate understanding than talking to management or reading analysis documentation for days. Business processes change, often the experts on that process are out of touch with what is actually going on. As well as getting a good detailed understand of what they do, and what their problems are, another benefit of watching users is how often there are tiny little changes you can make (trivial software changes like adding a shortcut, or making some non-modal) that can save each user huge amounts of time and stress everyday !

If you haven't sat and watched your users recently, you're probably not building a system that solves their real problems ! 

2 - It's all about incentive

A reiteration of the point about, but really a reminder to think of the incentives of each distinct groups of users. Management will have different incentives than the day to day users. It is worth thinking how to incentivise each different group to use the system in the way you want it used.

3 - Mastery of language is important

The language you use, both in your application, but especially when communicating ideas and progress to project sponsors, is incredibly important. Firstly words are very powerful in the human mind, they are the key way we link thoughts, feelings, expectations and fears together. The project I have been working on was half way through when I came on board, and because it was late and not delivering, had a number of perceptions, worries and expectations, all hanging off the 'name' of the project. One of the first things the team did was change the project name. This gave us a blank sheet to work with, meant that people's previous perceptions were 'invalidated', giving us breathing room to solve the problems in a different way.

Secondly, unless you use terms like Risk and Trade-off, management and sponsors won't consider these things. Just by using the words, you can make them better consider that they are asking for, and incentivise them to make better decisions (I am labouring the theme enough yet ? ;-)

4 - Its easier if you don't care

I am an outside supplier, so it is much easier for me to tell people the situation as is, rather than having to worry too much about internal politics. You obviously don't go out of your way to cause problems, and need be sensitive to the people from the business that you work with who don't have the same freedoms as you, but being truthful about situations is very important to the overall success of a project. Having said that, obviously always keep copies of all emails, and confirm verbal conversations via email, so you always have an audit trail to support your decisions.

5 - Avoid the middle men

In any remotely large business there will tend to be lots of layers of management (unless you work somewhere very groovy like Google Inc). Each layer will have there own agendas, desires and aims, and will wish to communicate information in ways that either make them look good or at least reduce how bad they look. Whilst this is understandable, and just human nature, projects are much more successful if you can talk honestly to the ultimate users at one end of the spectrum, and the key sponsors / decision makers at the other end. The more layers in the way, the more the problems, drivers, issues, etc. get obscured and less clear. Politically this can be hard, and take time, but it is worth it in the end.

6 - Flexibly and Power => Complex and slow

This is really a more concrete example of the trade-off principle. Flexibility and powerful is what everybody wants their computer systems to be. However these two requirements ALWAYS imply complexity, and complexity implies complex (and potentially) slow running software. The art of being a good designer or architect is coming up with abstractions that are both powerful and a simple as possible, but always remember that powerful and flexibly implies clever decision making which implies complexity. Bacteria are very simple, but don't do a huge amount but breed. Look at the complexity, both in body and mind, to get something as flexible and powerful as a human being. Fight to keep things simple, and your are much more likely to get a working solution ready in time.

A good example of this is the control issue. Management quite often want to stop people using systems in certain 'incorrect' ways (not entering data in certain ways, formats, sequences, whatever) . Often their approach is to wrap these systems in further layers that prevent the 'incorrect' use from occurring. Two problems with this though: 1. It's loads of work and 2. There are often certain exceptional situations where it is necessary to put in data 'incorrectly'. Often the simpler approach is just to provide an exception report. Management can use this to make sure systems are being used correctly, and if there is a valid reason using it wrongly, its not a problem. Making it a management rather than IT issue.

7 - Easy to think != Easy to do. Details matter

This is obvious to developers, but sometime can be hard to communicate to project sponsors. It is something I still have problems with conveying successfully. Steve Yegge [discusses](http://steve.yegge.googlepages.com/nonesuch-beast) the same point. For the same 'lazy' reasons as discussed at the start, people don't think through what they are asking for, and whilst this is annoying, your job as a technical analyst is to communicate the consequences of what people are asking for. In a similar vein, any technology you have been asked to use should be 'proof of concept'ed as quickly as possible. Things often work in principle, but in practise are too buggy, slow or unreliable to actually use in production systems. Ultimately this is why I don't trust analysts who can't program, they never understand the need to capture the exact details of a project, because they don't actually have to build working systems, they don't really realise its importance.

---

Hope this list is useful for somebody. I'm off to work out what the trade-offs and incentives for writing blog articles are ;-)