module SalesforceOrm
  def self.root
    File.dirname __dir__
  end
end

Dir[File.expand_path('salesforce-orm/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end
