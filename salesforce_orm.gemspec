require
Gem::Specification.new do |s|
  s.name        = 'salesforce-orm'
  s.version     = '1.0.0'
  s.date        = '2017-06-07'
  s.summary     = "Ruby ORM for Salesforce"
  s.description = "Active record like ORM for Salesforce"
  s.authors     = ['Vishal Viay', 'Shivansh Gaur']
  s.email       = '0vishalvijay0@gmail.com'
  s.files       = Dir['README.md", 'LICENSE', 'lib/**/*'']
  s.homepage    = 'https://github.com/NestAway/salesforce-orm'
  s.license     = 'Apache License 2.0'

  s.required_ruby_version = '>= 1.9.8'
  s.require_paths = ['lib']

  s.add_dependency 'activerecord'
  s.add_dependency 'restforce', '~> 2.5.0'
end
