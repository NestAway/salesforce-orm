lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'salesforce_orm/version'

Gem::Specification.new do |s|
  s.name        = 'salesforce-orm'
  s.version     = SalesforceOrm::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.date        = '2017-06-07'
  s.summary     = 'Ruby ORM for Salesforce'
  s.description = 'Active record like ORM for Salesforce'
  s.authors     = ['Vishal Vijay', 'Shivansh Gaur']
  s.email       = ['tech_team@nestaway.com', '0vishalvijay0@gmail.com']
  s.files       = `git ls-files`.split("\n").reject do |f|
    f.match(%r{^(spec)/})
  end
  s.homepage    = 'https://github.com/NestAway/salesforce-orm'
  s.license     = 'Apache License 2.0'

  s.required_ruby_version = '>= 1.9.8'
  s.require_paths = ['lib']

  s.add_dependency 'activerecord', '~> 3'
  s.add_dependency 'activerecord-nulldb-adapter', '~> 0'
  s.add_dependency 'restforce', '~> 2.5'

  s.add_development_dependency 'byebug', '~> 0'
  s.add_development_dependency 'bundler', '~> 1.15'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.0'
end
