require 'salesforce_orm'

class A < SalesforceOrm::ObjectBase
end

puts A.where(1).to_soql
