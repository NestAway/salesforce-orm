require 'forwardable'
require 'time'
require_relative 'sql_to_soql'

module SalesforceOrm
  class Base

    include Enumerable, SqlToSoql
    extend Forwardable

    def_delegators :make_query, *([
      :each,
      :empty?,
      :size,
      :map,
      :inspect
    ] + Enumerable.instance_methods)

    attr_reader :builder, :client, :klass

    def initialize(klass)
      unless klass.singleton_class.included_modules.include?(ObjectMaker)
        raise Error::CommonError, "Salesforce object has to be extended from #{ObjectMaker.name}"
      end

      @klass = klass
      @client = RestforceClient.instance
      @builder = QueryBuilder.select(klass.field_map.keys)
      where(RecordTypeManager::FIELD_NAME => klass.record_type_id) if klass.record_type_id
    end

    # create! doesn't return the SalesForce object back
    # It will return only the object id
    def create!(attributes)
      new_attributes = map_to_keys(attributes)

      new_attributes = new_attributes.merge(
        RecordTypeManager::FIELD_NAME => klass.record_type_id
      ) if klass.record_type_id

      client.create!(klass.object_name, new_attributes)
    end

    # Transaction not guaranteed
    def destroy_all!(*args)
      each do |object|
        object.destroy!(*args)
      end
    end

    def destroy_by_id!(id)
      client.destroy(klass.object_name, id)
    end

    def destroy!(object)
      destroy_by_id!(object.id)
    end

    # Transaction not guaranteed
    def update_all!(attributes)
      each do |object|
        object.update_attributes!(attributes)
      end
    end

    def update_by_id!(id, attributes)
      client.update!(
        klass.object_name,
        map_to_keys(attributes.merge({id: id}))
      )
    end

    def update_attributes!(object, attributes)
      update_by_id!(object.id, attributes)
    end

    # Handling select differently because we select all the fields by default
    def select(*args)
      @results = nil
      except(:select)
      @builder = builder.select(*args)
      self
    end

    [
      :scoped,
      :except,
      :where,
      :group,
      :limit,
      :offset,
      :order,
      :reorder
    ].each do |method_name|
      define_method(method_name) do |*args|
        @results = nil
        @builder = builder.send(method_name, *args)
        self
      end
    end

    def all(*args)
      make_query
    end

    def first
      limit(1).make_query.first
    end

    def last
      order('created_at DESC').first
    end

    def to_soql
      sql_to_soql(builder.to_sql)
    end

    def make_query
      return @results if @results
      @results = begin
        soql = to_soql
        client.query(to_soql).find_all.map do |object|
          build(object)
        end
      rescue => e
        # On passing a invalid object id, salesforce throughs an exception
        # with message starting with INVALID_QUERY_FILTER_OPERATOR, we'll be
        # considering this as an ObjectNotFound exception
        if e.message =~ /^INVALID_QUERY_FILTER_OPERATOR/
          raise Error::ObjectNotFound
        else
          raise
        end
      end
    end

    def build(object)
      result = klass.new(map_from_keys(object))
      result.original_object = object
      result
    end

    private

    def map_to_keys(attributes)
      map = klass.field_map
      new_attributes = {}
      attributes.keys.each do |key|
        key_sym = key.to_sym
        new_attributes[map[key_sym]] = attributes[key] if map[key_sym]
      end
      new_attributes
    end

    def map_from_keys(attributes)
      map = klass.field_map
      data_type_map = klass.data_type_map
      new_attributes = {}
      attributes.keys.each do |key|
        key_sym = key.to_sym
        new_key = map.key(key_sym)
        if new_key
          new_attributes[new_key] = cast_to(
            value: attributes[key],
            data_type: data_type_map[new_key]
          )
        else
          # The feilds which is not in field_map also will get added
          # to the ObjectBase, to support aggregate queries
          new_attributes[key] = attributes[key]
        end
      end
      new_attributes
    end

    def cast_to(value:, data_type:)
      case data_type
      when :integer
        value.to_i
      when :float
        value.to_f
      when :date_time
        time_parse(value: value)
      when :date
        time_parse(value: value).try(:to_date)
      when :array
        return [] if value.blank?
        value.split(';')
      else
        value
      end
    end

    def time_parse(value:)
      return nil if value.blank?
      if Time.respond_to?(:zone) && Time.zone
        Time.zone.parse(value)
      else
        Time.parse(value)
      end
    end

  end
end
