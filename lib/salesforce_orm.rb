Dir[File.expand_path('salesforce_orm/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end

module SalesforceOrm
end
