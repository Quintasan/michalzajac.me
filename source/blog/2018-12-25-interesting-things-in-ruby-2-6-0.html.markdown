---
title: Interesting things in Ruby 2.6.0
author: Michał Zając
tags: ruby
---

Every year matz gives every Ruby programmer a present on December 25th. This year is no exception and Ruby 2.6.0 was
released and brings a slew of new features. The changelog is available on [ruby-lang.org](https://www.ruby-lang.org/en/news/2018/12/25/ruby-2-6-0-released/) and I decided to write about a subset of new features which are of particular interest to me.

# Bundler is now installed as a default gem.

From Ruby 2.6 onwards Bundler will be available by default. This means that you no longer have to worry about things like having to install bundler in your CI system or getting `command not found` errors when you install a new Ruby version.

With Ruby 2.6 we get Bundler 1.17.2

# Add function composition operators `<<` and `>>` to `Proc` and `Method`

While you could simply implement it yourself it's a nice addition to those who like programming in a functional style. With this feature you can do things like:

```ruby
emphasis = proc { |text| "<em>#{text}</em>"}
header = proc { |text| "<h1>#{text}</h1>" }
(header << emphasis).call("Hello world") # => "<h1><em>Hello world!</em></h1>"
(header >> emphasis).call("Hello world") #> "<em><h1>Hello world!</h1></em>"
```

# Add an alias of `Kernel#yield_self` named `#then`

Another of "the naming could be improved" issues but

```ruby
URL
  .then(&HTTParty.method(:get))
  .body
  .then(&JSON.method(:parse))
  .dig("title")
```

reads way better than all those `yield_self`.

# JIT

Ruby 2.6 has an initial version of a JIT compiler written by Vladimir Makarov. While definitely a [big step](https://gist.github.com/k0kubun/d7f54d96f8e501bbbc78b927640f4208) for Ruby in terms of CPU performance it apparently makes Rails [run slower](https://github.com/ruby/ruby/commit/ed935aa5be0e5e6b8d53c3e7d76a9ce395dfa18b). I'll probably conduct some benchmarks on my own but I think I'll steer clear of the JIT for now.

# RubyVM::AbstractSyntaxTree module

This one has a `#parse` and a `#parse_file` methods which basically take a `String` or a `File`, parse it as Ruby code and return an Abstract Syntax Tree nodes of the code.

```ruby
test = RubyVM::AbstractSyntaxTree.parse("class Test; attr_accessor :x, :y; end")
test.children[2].children[2].children[2].children[1].children[0] # => :attr_accessor
```

I have no clue if this thing has any uses unless you are writing a script that modifies an existing Ruby script

# In short

Nothing revolutionary but another step towards Ruby 3x3 and making Ruby a programmer's best friend. Warmly waiting for Ruby 2.7 next year.
