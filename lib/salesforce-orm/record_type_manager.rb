module SalesforceOrm
  module RecordTypeManager

    FIELD_NAME = :RecordTypeId

    def record_type=(new_record_type)
      @record_type = new_record_type
    end

    def record_type
      @record_type
    end

    def record_type_id
      return nil unless record_type
      return @record_type_id if @record_type_id

      record_type_sobject = if defined?(Rails)
        if Rails.env.test?
          Object::RecordType.build(id: 'fake_record_type')
        elsif !Rails.env.development?
          id = Rails.cache.fetch(record_type_cache_key) do
            fetch_record_type.id
          end
          Object::RecordType.build(id: id)
        else
          fetch_record_type
        end
      else
        fetch_record_type
      end

      raise Error::RecordTypeNotFound unless record_type_sobject

      @record_type_id = record_type_sobject.id
    end

    private

    def fetch_record_type
      Object::RecordType.where(developer_name: record_type).first
    end

    def record_type_cache_key
      ['RecordTypeManager', object_name, record_type].join('/')
    end
  end
end
