require_relative '../object_base'

module SalesforceOrm
  module Object
    class RecordType < ObjectBase

      self.field_map = {
        name: :Name,
        sobject_type: :SobjectType,
        developer_name: :DeveloperName,
      }

    end
  end
end
