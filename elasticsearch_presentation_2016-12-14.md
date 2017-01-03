# Elasticsearch

## Let's use it

---

## Overview

* What do we use Elasticsearch for?
* Deeper dive into the API
* Incorporating Elasticsearch into a Rails app using `chewy` gem

---

## What do we use Elasticsearch for?

* Faster querying
* Doing stuff that's hard in SQL

^ I think of an elastic search kind of like a cache.  You trade a little bit of speed when writing data because you have to go update the index (or cache) with the model's new attributes or a result of a function call, and you get a lot better performance when reading data in many cases.

^ You can keep your database very DRY and normalized more easily this way.

^ Easiest way to explain how this works is to create a new Rails app

---

## Using Elasticsearch in a Rails app

* [chewy](https://github.com/toptal/chewy) gem

* Demo app: KlassPass.  Users do the following:
  - Attend exercise classes.  They rate them on a 1-5 score on various attributes afterwards.
  - Search classes by name via `GET /exercise_classes` -> use Elasticsearch
  - Order classes by their average rating across all attributes by default

---

## I. Initial app setup

* Repo: https://github.com/IntrepidPursuits/klass_pass_elasticsearch_tutorial
* Data model / ER Diagram
* Endpoint

^ You'll see that in our `ExerciseClassesController`, we're calling this `ExerciseClass.search` method that takes a query param and fetches all classes with that query parameter in their name, or just all the classes if no query parameter is passed.

---

## II. Install Elasticsearch & start the server

```
$ brew update
$ brew install elasticsearch
$ brew services start elasticsearch
```

Add `chewy` gem & run `rails g chewy:install`

---

## III. Using the `chewy` gem

1. Create an index
2. When a record is added or changed, update the associated index(es)
3. Query the index!

---

## III.A. Create an index

```ruby
# app/chewy/exercise_classes_index.rb

class ExerciseClassesIndex < Chewy::Index
  define_type ExerciseClass.includes(:ratings) do
    # primary and foreign keys
    field :id, type: 'integer'
    field :studio_id, type: 'integer'
    field :category_id, type: 'integer'

    # other attributes
    field :name, type: 'string'
    field :description, type: 'string'
    field :created_at, type: 'date', index: 'not_analyzed'
    field :updated_at, type: 'date', index: 'not_analyzed'
  end
end
```

^ A type is a logical category/partition of your index whose semantics is completely up to you. In general, a type is defined for documents that have a set of common fields.

^ I'm starting off here with just the attributes on the corresponding `exercise_classes` database table, but we'll add more interesting stuff later.  As you can see we specify a the name and the datatype for each field.

---

## III.B. Update the index

```ruby
# observe the appropriate index(es)
class ExerciseClass < ApplicationRecord
  # ...
  update_index('exercise_classes') { self }
end

# update observed indexes when you add/update a record
Chewy.strategy(:atomic) do
  # create / update an exercise class
end
```

^ Now we need to make sure that each time the `ExerciseClass` model changes, we update the index.  We do this by calling `update_index` on the model, telling it which index to update, and which item is affected. (If you have multiple types in an index, you can also specify the type here.)

^ Now, this isn't quite enough to ensure that the index is updated.  We also have to wrap any code that modifies an exercise class inside a `Chewy.strategy` block.

^ wrap seeder code

---

## III.C. Query the index

At a high level:

  ```ruby
  query = {
    # create JSON using ES query language
  }

  ExerciseClassesIndex.query(query)
  ```

But what goes in that query gets complicated!

^ So let's take a look at the Elasticsearch Search API before we do anything else.

---

## IV. The Elasticsearch Search API

* Pretty complicated DSL - check out the docs [the docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
* Demo in Postman

^ Elasticsearch provides some handy APIs for simply checking on your indices.  For example, let's: (1) hit the endpoint to list all of our indices. (2) fetch information about our `exercise_classes` index.

^ Now lets take a look at the search API.  At it's simplest, we can append a `_search` segment to our URL and pass in a query parameter.  

^ However, the DSL gets much more complicated.  Instead of just passing a query param in the URL, we can pass a whole chunk of JSON in the request body.

---

## IV. The Elasticsearch Search API, cont'd.

```
// first 5 classes, sorted by name
GET http://localhost:9200/exercise_classes/_search

{
  "query": { "match_all": {} },
  "sort": [
    { "name": "asc" }
  ],
  "from": 0,
  "size": 5
}
```

^ note on GET & POST

---

## IV. The Elasticsearch Search API, cont'd.

* `match` and `match_phrase`

```json
// return records with name including 'Yoga'
{ "query": { "match": { "name": "Yoga" } } }

// return records with name including 'hip hop'
{ "query": { "match_phrase": { "name": "hip hop" } } }
```

---

## IV. The Elasticsearch Search API, cont'd.

* `bool` (with `should`, `must`, and `must_not`)

```json
{
  "query": {
    "bool": {
      "must": [{ "match": { "name": "yoga" } }],
      "must_not": [{ "match_phrase": { "name": "hip hop" } }]
    }
  }
}
```

^ TODO: Should

---

## IV. The Elasticsearch Search API, cont'd.

* `filter` - for excluding sets of results. Doesn't affect the relevance score and is optimized.

```json
{
  "query": {
    "bool": {
      "must": { "match_all": {} },
      "filter": {
        "range": {
          "average_rating": {
            "gte": 4
          }
        }
      }
    }
  }
}
```

^  return all classes that have an average rating of at least 4

---

# Back to the app.

---

## V. Query the index in our `ExerciseClass.search` method

```ruby
def self.search(term: "")
  if term.present?
    query = {
      query: {
        match: {
          name: term
        }
      }
    }
  else
    query = {
      query: {
        match_all: {}
      }
    }
  end

  # returns an `ExerciseClassIndex::Query` object
  results = ExerciseClassesIndex.query(query)
  # pull out the class attributes
  class_attributes = results.to_a.map(&:attributes)
  # fetch the classes with the right IDs from the database
  class_ids = class_attributes.map { |attrs| attrs['id'] }
  find(class_ids)
end
```

^ Now visiting http://localhost:3000/exercise_classes?query=yoga in Postman, we can see we only get classes with yoga in the title.

---

## VI. Order by average score

```ruby
class ExerciseClassesIndex < Chewy::Index
  define_type ExerciseClass.includes(:ratings) do
    # ...
    field :average_score, type: 'float', value: ->(exercise_class) do
      exercise_class.average_score
    end
  end
end

class Rating < ApplicationRecord
  # ...
  update_index('exercise_classes') { exercise_class }
end
```

---

## VI. Order by average score, cont'd.

```ruby
def self.search(term: "")
  if term.present?
    query = {
      query: [
        { match: { name: term } }
      ],
      sort: {
        average_score: { order: 'desc' }
      }
    }
  else
    query = {
      query: [
        { match_all: {} }
      ],
      sort: {
        average_score: { order: 'desc' }
      }
    }
  end

  # ...
end
```

^ lots ot trial and error -- sometimes you have to put clauses in an array, sometimes you don't.

^ test in Postman

---

## Dynamic scripting

* Enables you to do calculations on the fly in your query
  - Can do in SQL, but starts to get tricky pretty fast
* Great for handling complex ordering logic
* Security considerations

^ I wanted to touch on one other feature of elasticsearch we've used in the past, which is dynamic scripting.

^ dynamic scripting allows you to run some code on the fly to, for example, order items in a particular way (that's how we've used it).  So for example say we want to do some calculat

---

## Dynamic scripting, cont'd.

Example:

* Order classes by a user's favorite categories (i.e. the type of classes they attend the most)
* Can do in SQL, but as what determines "relevance" gets trickier, gets harder
* Use "dynamic scripting" instead

---

## Dynamic scripting, cont'd

```ruby
top_rank = categories.count
script_score =
  "doc['category_id'].value * (#{top_rank} -
  #{user.category_ranks[doc['category_id'].value]})
  /#{top_rank}"
ExerciseClassesIndex.
  query(query).
  script_score(script_score)
```

---

## Questions?

---
