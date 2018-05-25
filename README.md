# salesforce-orm
Active record like ORM for Salesforce

[![Build Status](https://travis-ci.org/NestAway/salesforce-orm.svg?branch=master)](https://travis-ci.org/NestAway/salesforce-orm)

## Setup

Add gem to your Gemfile

```
gem 'salesforce-orm'
```

Or, If you want to install globally

```
gem install salesforce-orm
```

This Gem internally use [Restforce](https://github.com/ejholmes/restforce), So you have to configure it

There are 2 options to configure ([Restforce config](https://github.com/ejholmes/restforce#initialization))

**Option 1**

Set ENV variable as per Restforce doc

**Option 2**

In rails, write below code in application.rb or environment specific file

Other projects, run it before you use SaleforceOrm

```ruby
  SaleforceOrm::Configuration.restforce_config = {
    ... # Restforce configuration
  }
```

## Usage

Create object class

```ruby
class SampleObject < SalesforceOrm::ObjectBase
end
```

### object_name

Default object name is `class.name`

```ruby
SampleObject
```

If you have a custom object name,

```ruby
class SampleObject < SalesforceOrm::ObjectBase
  self.object_name = 'SampleObject__c'
end
```

### field_map

Field map is used for create, update actions. This can be used for aliasing the field names

Default field map for `SampleObject`

```ruby
  {
    id: :Id,
    created_at: :CreatedAt,
    updated_at: :UpdatedAt
  }
```

If you wanna map more fields for an object

```ruby
class SampleObject < SalesforceOrm::ObjectBase
  self.field_map = {
    field_one: :FieldOne,
    field_two: :FieldTwo__c,
  }
end
```

### data_type_map

Allowed data types are,

- `:integer`
- `:float`
- `:date_time`
- `:date`
- `:array`
- `:boolean`

Default is same data type of given value

Default data type map for `SampleObject`

```ruby
  {
    created_at: :datetime,
    updated_at: :datetime
  }
```

If you wanna change the data type of some fields

```ruby
class SampleObject < SalesforceOrm::ObjectBase
  self.data_type_map = {
    field_one: :datetime,
    field_two: :integer
  }
end
```

**NOTE: It's mandatory to add data type map for boolean fields**

### record_type

By default there is no record type configured for any object

To specify a record type,

```ruby
class SampleObject < SalesforceOrm::ObjectBase
  self.record_type = 'Xyz' # DeveloperName in RecordType object
end
```

All the queries and `create!` method will automatically use record type

First time use the object, we make a call to Salesforce and find the record type by it's `DeveloperName`. This will be cached in memory.

With Rails in except in development or test env, we take the advantage of `Rails.cache`

### Methods

Methods are similar to ActiveRecord::Base

Class methods

```ruby
SampleObject.[
  :create!,
  :update_all!,
  :destroy_all!,
  :where,
  :select,
  :except,
  :group,
  :order,
  :reorder,
  :limit,
  :offset,
  :first,
  :last,
  :each,
  :scoped,
  :all,
  :find_by_*
]
```

eg:
```ruby
SampleObject.where(id: 'qd')

SampleObject.where(id: ['eqd', 'qqwd'])

SampleObject.where(id: ['eqd', 'qqwd'], field_one: 'KJbn').where('a = b').all

SampleObject.where(id: 'qd').group(:a, :b).each do |sobj|
  puts sobj.id
end

SampleObject.find('qwd')

SampleObject.find_by_id('qwd')

SampleObject.find_by_field_one_and_field_two_and_field_three(1, 2, 3)

SampleObject.select('count(id)').all
```

**NOTE: Salesforce API's accepts SOQL query as a URL params, so make sure URL length is not longer than 16087 chars**

Instance methods

```ruby
SampleObject.[
  :update_attributes,
  :destroy
]
```

Other class methods (Specific to SalesforceOrm)

#### update_by_id!

To update an object by id

```ruby
SampleObject.update_by_id!('some_id', {feild_one: 'some_value', field_two: 'some_other_value'})
```

#### destroy_by_id!

To destroy an object by id

```ruby
SampleObject.destroy_by_id!('some_id')
```

#### to_soql

To generate, SOQL query (Equavalent to `to_sql`)

#### build

To create a new instance of SampleObject

```ruby
SampleObject.build({id: 'some id', field_one: 'Some value'})
```

## Troubleshooting

If you get following error on a threaded server

`ActiveRecord::ConnectionTimeoutError: could not obtain a database connection within 5 seconds (waited 5.000150138 seconds). The max pool size is currently 5; consider increasing it.`

Consider setting environment variable `NULLDB_MAX_POOL_SIZE` to a value greater than the max thread pool size.

## Pending

- Default values
- Relationships
- More data types
- Better aggregate methods

## Contributing

If you'd like to contribute a feature or bugfix: Thanks! To make sure your
fix/feature has a high chance of being included, please read the following
guidelines:

1. Post a [pull request](https://github.com/NestAway/salesforce-orm/compare).
2. Make sure there are tests! We will not accept any patch that is not tested.
   It's a rare time when explicit tests aren't needed. If you have questions
   about writing tests for salesforce-orm, please open a
   [GitHub issue](https://github.com/NestAway/salesforce-orm/issues/new).

Thank you to all [the contributors](https://github.com/NestAway/salesforce-orm/graphs/contributors)!
