$:.push File.expand_path("../lib", __FILE__)
require "salesforce_orm/version"

Gem::Specification.new do |s|
  s.name        = 'salesforce-orm'
  s.version     = SalesforceOrm::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.date        = '2017-06-07'
  s.summary     = 'Ruby ORM for Salesforce'
  s.description = 'Active record like ORM for Salesforce'
  s.authors     = ['Vishal Vijay', 'Shivansh Gaur']
  s.email       = 'tech_team@nestaway.com'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://github.com/NestAway/salesforce-orm'
  s.license     = 'Apache License 2.0'

  s.required_ruby_version = '>= 1.9.8'
  s.require_paths = ['lib']

  s.add_dependency 'activerecord'
  s.add_dependency 'restforce', '~> 2.5.0'
end
