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

```
  SaleforceOrm::Configuration.restforce_config = {
    ... # Restforce configuration
  }
```

## Usage

Create object class

```
class SampleObject < SalesforceOrm::ObjectBase
end
```

### object_name

Default object name is `class.name`

```
SampleObject
```

If you have a custom object name,

```
class SampleObject < SalesforceOrm::ObjectBase
  self.object_name = 'SampleObject__c'
end
```

### field_map

Field map is used for create, update actions. This can be used for aliasing the field names

Default field map for `SampleObject`

```
  {
    id: :Id,
    created_at: :CreatedAt,
    updated_at: :UpdatedAt
  }
```

If you wanna map more fields for an object

```
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
- `:date_time`
- `:array`

Default is same data type of given value

Default data type map for `SampleObject`

```
  {
    created_at: :datetime,
    updated_at: :datetime
  }
```

If you wanna change the data type of some fields

```
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

```
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

```
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
```
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

Instance methods

```
SampleObject.[
  :update_attributes,
  :destroy
]
```

Other class methods (Specific to SalesforceOrm)

#### update_by_id!

To update an object by id

```
SampleObject.update_by_id!('some_id', {feild_one: 'some_value', field_two: 'some_other_value'})
```

#### destroy_by_id!

To destroy an object by id

```
SampleObject.destroy_by_id!('some_id')
```

#### to_soql

To generate, SOQL query (Equavalent to `to_sql`)

#### build

To create a new instance of SampleObject

```
SampleObject.build({id: 'some id', field_one: 'Some value'})
```

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
