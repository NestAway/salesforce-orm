Dir[File.expand_path('salesforce-orm/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end

module SalesforceOrm
end
