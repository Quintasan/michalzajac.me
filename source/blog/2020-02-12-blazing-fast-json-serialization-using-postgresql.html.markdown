---
title: Blazing fast JSON serialization using PostgreSQL
author: Michał Zając
tags: ramblings
---

This post will show you how to leverage PostgreSQL features that allow you to serialize database records to JSON in your application. I'm 90% sure that people who work with PostgreSQL know about this but this managed to save my back many times. I eagerly await the day when `BREW TEA` is implemented since this is the only thing that I currently lack in PostgreSQL.

## Requirements

* PostgreSQL 9.3 or later

The earliest mention of `json_agg(expression)` I could find is [documentation for PostgreSQL 9.3](https://www.postgresql.org/docs/9.3/functions-aggregate.html). You're out of luck if you are running anything older than this (you shouldn't be anyway - it's unsupported).

## Aggregating values using `json_agg`

Let's assume we have a table named `cocktails` with several columns such as `name`, `ingredients` etc. We can get a JSON array with all of the cocktails using the following query:

```sql
SELECT
  json_agg(all_cocktails) AS all_cocktails
FROM (
  SELECT *
  FROM cocktails
) all_cocktails;
```

The result of this query will be one column named `all_cocktails` which will have one row, containing our JSON array.

```
cocktails
-----------
[{"id":1,"name":"Moscow Mule","youtube_link":"","ingredients":"","glassware":"","technique":"","garnish":"","signature":false,"menu":false,"category_id":1,"created_at":"2020-01-23T07:30:56.119767","updated_at":"2020-01-23T07:30:56.119767","image_data":null,"uuid":"128db793-8e1b-44cd-b6e6-3df51210331b"}, 
 {"id":2,"name":"Cuba Libre","youtube_link":"","ingredients":"","glassware":"","technique":"","garnish":"","signature":false,"menu":false,"category_id":2,"created_at":"2020-01-23T07:30:56.136525","updated_at":"2020-01-23T07:30:56.136525","image_data":null,"uuid":"a7ce2445-5c05-4c86-8aee-ae04bff3cec3"}, 
 {"id":3,"name":"Gin Fizz","youtube_link":"","ingredients":"","glassware":"","technique":"","garnish":"","signature":false,"menu":false,"category_id":3,"created_at":"2020-01-23T07:30:56.149179","updated_at":"2020-01-23T07:30:56.149179","image_data":null,"uuid":"34898fa6-e132-46ae-a531-6e907f1b4cb4"}, 
 {"id":4,"name":"Whisky Sour","youtube_link":"","ingredients":"","glassware":"","technique":"","garnish":"","signature":false,"menu":false,"category_id":4,"created_at":"2020-01-23T07:30:56.183716","updated_at":"2020-01-23T07:30:56.183716","image_data":null,"uuid":"fcdd7b95-5f39-4bbf-9eba-b575c9447643"}]
```

## Building objects with `json_build_object`

We wouldn't be able to get very far without the ability to build arbitrary JSON objects but PostgreSQL has us covered in that aspect as well.

Let's say we want to return the number of cocktails that we have in the database along with all the details:

```json
{
  "count": 4,
  "cocktails": [
    { "name": "Moscow Mule", "ingredients": "alcohol" },
    ...
  ]
}
```

We can easily get that using the following query:

```sql
SELECT 
  json_build_object(
    'count',
    MAX(cocktails.total),
    'cocktails',
    json_agg(all_cocktails)
  )
FROM (
  SELECT 
    *,
    COUNT(*) OVER() AS total
  FROM cocktails
) all_cocktails;
```

which gives us:

```
{"count" : 4, "cocktails" : [{"id":1,"name":"Moscow Mule","youtube_link":"","ingredients":"","glassware":"","technique":"","garnish":"","signature":false,"menu":false,"category_id":1,"created_at":"2020-01-23T07:30:56.119767","updated_at":"2020-01-23T07:30:56.119767","image_data":null,"uuid":"128db793-8e1b-44cd-b6e6-3df51210331b","total":4}, 
 {"id":2,"name":"Cuba Libre","youtube_link":"","ingredients":"","glassware":"","technique":"","garnish":"","signature":false,"menu":false,"category_id":2,"created_at":"2020-01-23T07:30:56.136525","updated_at":"2020-01-23T07:30:56.136525","image_data":null,"uuid":"a7ce2445-5c05-4c86-8aee-ae04bff3cec3","total":4}, 
 {"id":3,"name":"Gin Fizz","youtube_link":"","ingredients":"","glassware":"","technique":"","garnish":"","signature":false,"menu":false,"category_id":3,"created_at":"2020-01-23T07:30:56.149179","updated_at":"2020-01-23T07:30:56.149179","image_data":null,"uuid":"34898fa6-e132-46ae-a531-6e907f1b4cb4","total":4}, 
 {"id":4,"name":"Whisky Sour","youtube_link":"","ingredients":"","glassware":"","technique":"","garnish":"","signature":false,"menu":false,"category_id":4,"created_at":"2020-01-23T07:30:56.183716","updated_at":"2020-01-23T07:30:56.183716","image_data":null,"uuid":"fcdd7b95-5f39-4bbf-9eba-b575c9447643","total":4}]}
```

## Possible use cases

I mostly used this feature when I had to either dump some data from the database to import them elsewhere or to avoid bottlenecks when serializing in web applications. I'll briefly outline what problems did I have and how I used PostgreSQL to solve it.

### Exporting data from a database

One of projects I worked on involved moving a huge dataset from a MySQL-backed PHP application into a new shiny Node.js backend. Initially, I wanted to use the great [pgloader](https://pgloader.io/) but soon afterwards it turned out that [Waterline.js](https://waterlinejs.org/) had numerous problems with the data inserted. Much to my dismay, it turned out that the previous developer didn't bother to implement any validations on the database layer nor to use foreign key constraints. At this point we had no other viable options other than reimport the data using Waterline.js and manually fix the rows that were problematic. Of course, getting the data out of MySQL in a format that's easily readable by JavaScript is anything but easy. What I ended up doing was:

1. Migrate from remote MySQL database to a local PostgreSQL instance using pgloader.
2. Dump the whole database as a set of JSON files.
3. Load the JSON file in a script which would try to create records using Waterline.js ORM which had all of the validations and would throw exceptions whenever we tried to insert invalid data.

It's not the smartest solution for sure but at that point I wanted something boring and simple and which I knew wouldn't fail with some edge case.

### Avoiding serialization bottlenecks

Another project I worked on was a Ruby on Rails application using Ruby 2.1 (yes, I know it's EOL) and Active Model Serializers for the backend. We also had two clients: Ember web application and an Android mobile app. A major pain point was that it took horribly long for the web application to show custom fields for a group. Think about [20 seconds](https://stevenyue.com/blogs/migrating-active-model-serializers-to-jserializer) or more (I'm not surprised the folks at Netflix [rolled out their own serializer](https://netflixtechblog.com/fast-json-api-serialization-with-ruby-on-rails-7c06578ad17f)). A few days after I started working on the problem, it turned out that when the mobile client had to perform a full synchronization, it would time out while waiting for the data. Once again, PostgreSQL saved the day by doing the whole task in hundreds of milliseconds. 
