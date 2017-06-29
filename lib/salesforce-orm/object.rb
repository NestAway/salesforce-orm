Dir[File.expand_path('object/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end

module SalesforceOrm
  module Object
  end
end
