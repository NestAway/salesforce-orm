module SalesforceOrm
  module ObjectMaker

    DEFAULT_FIELD_MAP = {
      id: :Id,
      created_at: :CreatedDate,
      updated_at: :LastModifiedDate
    }

    DEFAULT_DATA_TYPE_MAP = {
      created_at: :date_time,
      updated_at: :date_time
    }

    def field_map=(field_map)
      @field_map = DEFAULT_FIELD_MAP.merge(field_map)
    end

    def field_map
      @field_map || DEFAULT_FIELD_MAP
    end

    def data_type_map=(data_type_map)
      @data_type_map = DEFAULT_DATA_TYPE_MAP.merge(data_type_map)
    end

    def data_type_map
      @data_type_map || DEFAULT_DATA_TYPE_MAP
    end

    def object_name=(new_name)
      @object_name = new_name
    end

    def object_name
      @object_name || name.demodulize
    end
  end
end
