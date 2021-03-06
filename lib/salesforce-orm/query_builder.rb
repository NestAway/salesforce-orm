require 'active_record'

module SalesforceOrm
  class QueryBuilder < ActiveRecord::Base

    DUMMY_TABLE_NAME = 'table_name'

    self.table_name = DUMMY_TABLE_NAME

    establish_connection(
      adapter: :nulldb,
      schema: (File.join SalesforceOrm.root, 'support', 'schema.rb')
    )
  end
end
