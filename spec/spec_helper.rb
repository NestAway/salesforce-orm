require 'bundler/setup'
require 'salesforce-orm'
require 'active_record'
require 'nulldb_rspec'

RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + "/..")

include NullDB::RSpec::NullifiedDatabase

NullDB.configure {|ndb| def ndb.project_root;RAILS_ROOT;end}


# Fix to make nulldb to work with Rspec
ActiveRecord::Base.configurations.merge!(
  'test' => {
    'adapter' => 'nulldb',
    'schema' => File.join(RAILS_ROOT, 'spec', 'fixtures', 'schema.rb')
  }
)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # config.before(:each) do
  #   schema_path = File.join(RAILS_ROOT, 'spec', 'fixtures', 'schema.rb')
  #   NullDB.nullify(schema: schema_path)
  # end

  # config.after(:each) do
  #   NullDB.restore
  # end
end
