---
title: Powerful params validation with dry-validation
author: Michał Zając
tags: ruby, rails
---

By default, Rails ships with Strong Parameters enabled which is a Good Thing. Strong Parameters force you to clearly state what values shall be accepted on certain endpoints. This is a security measure which also prevents users from sending invalid requests. The API is quite simple and looks like this:

```ruby
params.require(:tea).permit(:name, :country)
```

which basically says that the request MUST contain a key named `tea` and that key CAN have keys `name` and `country`. Any additional params are filtered out. You can access values from params using Hash-like API but remember we're actually dealing with `ActionController::Parameters` object which behaves like a Hash but is not actually a Hash.

My problem with Strong Parameters is that it allows you to mark things as required or allowed... and that's pretty much it. Pretty weak for a validation system.

## Enter dry-validation

[dry-validation](https://dry-rb.org/gems/dry-validation) is one of the gems from [dry-rb](https://dry-rb.org/) collection which, as you could probably guess, deals with validating things. It's a very powerful DSL for defining schemas and validations. The core idea here is that we have a contract object which tells you what values are needed, what's the appropriate type and what rules should the values respect. A short example would be:

```ruby
class NewTeaContract < Dry::Validation::Contract
  SWEAR_WORDS_REGEX = /(twice\ steeped\ earl\ grey)/ix.freeze
  COUNTRY_CODES_REGEX = /(pl|en|jp|gb)/ix.freeze

  params do
    required(:name).filled(:string)
    required(:country).filled(:string, max_size?: 2)
    optional(:price).filled(:integer, gt?: 0)
  end

  rule(:name) do
    unless SWEAR_WORDS_REGEX.match?(value)
      key.failure('contains offensive words')
    end
  end

  rule(:country) do
    unless COUNTRY_CODES_REGEX.match?(value)
      key.failure('must be a known country code')
    end
  end
end

contract = NewTeaContract.new.call(name: "Nice tea", country: "ER", price: "20")
#<Dry::Validation::Result{:name=>"Nice tea", :country=>"ER", :price=>"20"} errors={:country=>["must be a known country code"]}>
```

Here we have a very clear defintion of what attributes we expect, what is their expected type and what values are allowed. dry-validation has three ways for defining schemas: `schema`, `params`, `json`. The main difference between them is coerctions they perform on the input values. `schema` performs no coerctions. `params` will perform coerctions from Strings (eg. values will be coerced from String into Integer) before performing validations. `json` will perform coercion specific to JSON (JSON supports integers natively so no coerction so it will not coerce String values into Integer).

Now, let's see on how can we make use of dry-validation in our application instead of using Strong Parameters. To get this done we need to:

1. Somehow disable/get rid of Strong Params
2. Create a contract that we're going to use
3. Tie that contract into our controller
4. Explore options for enforcing contract usage in controllers

## Disabling Strong Params

Getting rid of Strong Params from Rails would be a really time consuming task and would probably require some monkey-patching which I'm not a big fan of. Looking at [ActionController::Parameters docs](https://api.rubyonrails.org/classes/ActionController/Parameters.html) there's one option that looks promising - `permit_all_parameters`. When set to `true`, all parameters will be accepted. Not exactly what we were looking for but gets the job done.

## Creating a contract

We already have a contract so the only question remaining is where to put it. I usually go with `app/contracts/`. In this particular example we would end up with `app/contracts/new_tea_contract.rb`. dry-validation itself doesn't really concern itself with where you store the contracts so it's really up to you where to store them.

## Tying the contract into controllers

I am a firm believer of "skinny controllers" but I see two approaches here:

1. Call the contract inside your controller methods and pass valid parameters to your service objects (you're using service objects, right?)
2. Call the contract inside your service object and extend it to return validation errors

When I'm working on a greenfield project the best choice is the second one but I can see merit in the first approach. There's no need to refactor everything right away when you are trying to integrate dry-validation into an existing project.

## Enforcing contract usage in controllers

The best mechanism to enforce contract usage I found so far consists of two components:

1. Defining a `#contract` method on `ApplicationController` and overriding that method in every controller.
2. A Rubocop rule to disallow using plain `params` unless they are passed to `#call` class.

### ApplicationController and contracts

IMO the best way to do this is the simplest way:

```ruby
def ApplicationController < ActionController::Base
  class ContractNotSupplied < NoMethodError; end

  protected

  def contract
    raise ContractNotSupplied
  end
end
```

In case you're wondering why I'm not raising `NotImplementedError` - it's superclass is `ScriptError` which will not be caught by `rescue` when it's not given an explicit type. If we raised `NotImplementedError` here then

```ruby
def new
  values = contract.new.call(some: "value", another: "value")
rescue
  # Won't get here if `NotImplementedError` is raised
end
```

Besides `NotImplementedError` has a [totally different meaning](https://ruby-doc.org/core-3.0.0/NotImplementedError.html) than what most people assume.

### Rubocop cop

This is a tough cookie and the only thing I can say at this moment is that I am still working on a cop that should work in most contexts and doesn't rely on class naming. My rough idea here is to forbid using `params` except when passed to `#call`. Not exactly ideal but should work. You can of course violate this in many ways but I think the idea is to catch unintentional violations.