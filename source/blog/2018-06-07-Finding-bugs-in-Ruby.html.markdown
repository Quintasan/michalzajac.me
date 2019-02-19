---
title: Finding bugs in Ruby
author: Michał Zając
tags: ruby
---

As some people may know I happen to maintain an Ruby API wrapper for [Woodpecker](http://woodpecker.co). Some time ago a
friend of mine who works there gave me a heads up that they would be updating the API. I decided to give the code a
cleanup before doing anything else. Among the things I decided to change was to migrate to use the `Time` class instead
of `DateTime`. This apparently introduced a [regression](https://github.com/Quintasan/woodpecker/issues/1).

The date returned by Woodpecker's API is as follows – `2018-05-17T12:17:11+0200`. My first thought was that this
somehow isn't a valid ISO8601 date. A quick glance at the ever (un?)trusty
[Wikipedia](https://en.wikipedia.org/wiki/ISO_8601) confirmed my idea. The colon between hours and minutes in the time
zone designator was missing. I decided that `DateTime` is behaving incorrectly – it should error out the same way that
`Time` does when provided an invalid format. I quickly filed a [bug report](https://bugs.ruby-lang.org/issues/14790) and
called it day thinking it won't get fixed any time soon (people should be busy with Ruby 3x3, right?).

Not only was I wrong about the colon being mandatory in the time zone designator, but I was also wrong about the time it
took to fix the bug. A mere 2 hours.

In the end I used `Time.parse` and made sure the library still works as intended. It sure was fun.
