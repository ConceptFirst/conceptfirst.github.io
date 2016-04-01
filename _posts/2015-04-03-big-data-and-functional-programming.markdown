---
layout: post
title: "Big data and functional programming"
date: 2015-04-03 10:51:13 +0100
comments: true
categories: Cloud Data
---

As we work more with big data, analysing large swathes of information, we are increasingly looking at functional programming languages for our development.

Recently I've been learning, and working with, the [F#](http://fsharp.org) programming language, originally developed by [Microsoft Research](http://en.wikipedia.org/wiki/Microsoft_Research) and now released as [Open Source on github](https://github.com/fsharp/fsharp).

![MS Research logo](/files/microsoft_research.png)
<!--more-->

Functional programming has been on the rise recently, even since the advent of multi-core processors. Traditional OO languages are designed around the concept for mutability, and this makes it especially challenging to write code that is robust when running concurrently. 

Functional programming is, by design, immutable, with message passing and immutable data structures meshing perfectly with highly concurrent computation.

One of the most interesting thing about Functional Programming is it's links with mathematics, and with higher level of abstractions such as Monoids and Monads (from an area of maths called category theory).

I'm not going to discuss Monads (they are just [monoids in the category of endofunctors](http://stackoverflow.com/questions/3870088/a-monad-is-just-a-monoid-in-the-category-of-endofunctors-whats-the-problem) after all ;-), or go into great detail, but monoids are a confusing name for a simple mathematical concept.

The concept is around breaking a mathematical problem into a definition that allows:

- _Incremental calculation_: you've just calculated the mean of 100 million numbers, and a new one has just been recorded, how do you incrementally update your answer without recalculating everything ?
- _Parallel calculation_: divide and conquer is the classic parallel data strategy, how do we split up a big calculation into lots of little ones, run them, and put it all back together.

If you can show your calculation is a monoid, you get the advantages listed above for free.

Sound like this would be helpful in cloud computing at all ?  ;-)

These formulations have been around forever, they are the basis of [Map Reduce](https://en.wikipedia.org/wiki/MapReduce), of distributed databases, etc.

The interesting thing is when you can capture and operate on them within your programming language. F# is very powerful, and has something called _Computation Expressions_. This allows you to extend the language to support home grown monads, monoids, and other different models of computation (e.g. asynchronous processing).

There is a wonderful library called [MBrace](http://www.m-brace.net), which adds computation expressions to F# that allow you to very easily take your computations and move them straight into the cloud. 

For example, if you have a simple function that prints the time you just need to put `cloud {}` around the calls and you can run it on azure:

![mbrace example](/files/mbrace.png).

The framework will handle all the communication, spinning up servers, exception handling etc. If you're used to 'async/await' in C#, it's like that, but for the cloud.

Model your data as monoids, and you can suddenly run your data analysis in parallel, without a massive investment in infrastructure and tooling.

For more examples have a quick look at the [MBrace programming model](http://www.m-brace.net/programming-model.html)

Their code is opensource on [github](https://github.com/mbraceproject)

I'm loving F#, and with the cloud and big data on the rise, these functional concepts are becoming ever more important.


Further details:

- [Understanding Monoids](http://fsharpforfunandprofit.com/series/understanding-monoids.html)
- [Understanding Computation Expressions](http://fsharpforfunandprofit.com/series/computation-expressions.html)
- [MSDN Computation Expressions](https://msdn.microsoft.com/en-us/library/dd233182.aspx)
- [Cloud computing with MBrace](http://www.slideshare.net/EirikGeorgeTsarpalis/mbrace-cloud-computing-with-f)
- [Cloud computing with F# generally - azure, amazon, etc.](http://fsharp.org/guides/cloud/)
