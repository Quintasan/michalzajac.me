---
title: Moving from Sinatra to Hakyll
author: Michał Zając
tags: haskell
---

Being a lazy person I decided to learn Haskell (pun not intended). Since learning is a tedious task I usually have to force myself to keep studying. That said, I decided to take an alternative approach to the problem. Insted of mindlessly consuming tutorials and whatnot I decided to take a hands-on approach and move my personal website from a simple [Sinatra](http://www.sinatrarb.com) application to [Hakyll](http://jaspervdj.be/hakyll).

## What's Hakyll?

If you're not familiar with static site generators then you might be wondering what is this all about. Those generators basically take your content (say - posts), apply templates to them and save the result as a ready-to-publish static website. "Why bother at all?", you may ask. Quite simple:

1. You can write your posts in whatever format you want --- Hakyll is integrated with [Pandoc](http://pandoc.org/README.html#description), a swiss-army knife for text conversion which can read virtually any markup format.
2. You can keep your site under version control. This is a huge feature for me since I can easily return to any state my site was at any given time.
3. Easy deployments --- just copy the files over to your server. You just need any kind of HTTP server.

## How does that work?

Working on a Hakyll powered site is relatively simple:

1. Write in whatever markup format you want.
2. Write compilation rules in Haskell <abbr title="Embedded Domain Specific Language">EDSL</abbr>. The default rules are definitely enough if you want a simple blog.
3. [SHIP IT!](http://media.giphy.com/media/143vPc6b08locw/giphy.gif)

I'm not really going to go into details here. Hakyll has some [tutorials](http://jaspervdj.be/hakyll/tutorials.html) which should do the explanation better than me and will teach you how to enhance you site with things such as Atom feed or producing multiple versions of a single file.

## Was it worth?

Definitely. I really recommend trying Hakyll out if you are looking for a simple way to create your own homepage. This was also a nice opportunity to brush up on my rusty CSS skills. I also plan to make the source code of this site public at a later point but first I need to check out [Clay](http://fvisser.nl/clay).
