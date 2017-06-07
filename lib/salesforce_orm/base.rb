module SalesforceOrm
  class Base

    include Enumerable
    extend Forwardable

    def_delegators :make_query, *([:each] + Enumerable.instance_methods)

    attr_reader :builder, :client, :klass

    def initialize(klass)
      unless klass.singleton_class.included_modules.include?(ObjectMaker)
        raise Error::CommonError, "Salesforce object has to be extended from #{ObjectMaker.name}"
      end

      @klass = klass
      @client = RestforceClient.instance
      @builder = QueryBuilder.select(klass.field_map.keys)
    end

    # create! doesn't return the SalesForce object back
    # It will return only the object id
    def create!(attributes)
      client.create!(klass.object_name, map_to_keys(attributes))
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
      client.destroy(klass.object_name, object.id)
    end

    # Transaction not guaranteed
    def update_all!(attributes)
      each do |object|
        object.update_attributes!(*args)
      end
    end

    def update_by_id!(id, attributes)
      client.update!(
        klass.object_name,
        map_to_keys(attributes.merge({id: id}))
      )
    end

    def update_attributes!(object, attributes)
      client.update!(
        klass.object_name,
        map_to_keys(attributes.merge({id: object.id}))
      )
    end

    [
      :select,
      :scoped,
      :except,
      :where,
      :group,
      :limit,
      :offset,
      :order
    ].each do |method_name|
      define_method(method_name) do |*args|
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
      order('created_at DESC').first!
    end

    def to_soql
      sql_to_soql(builder.to_sql)
    end

    def make_query
      begin
        soql = to_soql
        Rails.logger.info "\n\n\n}-------SOQL---#{soql}-------\n\n\n"
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
          # to the Salesforce::Object, to support aggregate queries
          new_attributes[key] = attributes[key]
        end
      end
      new_attributes
    end

    def cast_to(value:, data_type:)
      case data_type
      when :integer
        value.to_i
      when :date_time
        return nil if value.blank?
        Time.zone.parse(value)
      when :array
        return [] if value.blank?
        value.split(';')
      else
        value
      end
    end

    def aggregate_function?(keyword)
      keyword =~ /^(AVG|COUNT|COUNT|COUNT_DISTINCT|MIN|MAX|SUM)\(/i
    end

    def convert_aliased_fields(sql_str, split_by = Regexp.new('\s+'), join_by = ' ')
      spcial_char_regex = /[=<>!,]+/
      sql_str.split(split_by, -1).map do |keyword|
        if aggregate_function?(keyword)
          aggregate_data = keyword.match(/^(.*)\((.*)(\).*)/i).captures
          raise Error::CommonError, 'Invalid aggregate function' unless aggregate_data[1]
          "#{aggregate_data[0]}(#{convert_aliased_fields(aggregate_data[1])}#{aggregate_data[2]}"
        elsif keyword =~ spcial_char_regex
          convert_aliased_fields(keyword, spcial_char_regex, keyword.gsub(spcial_char_regex).first)
        else
          klass.field_map[keyword.to_sym] || keyword
        end
      end.join(join_by)
    end

    def boolean_data_type_conversion(sql)
      klass.data_type_map.each do |keyword, data_type|
        if data_type == :boolean
          [0, 1].each do |value|
            regex = Regexp.new("\s+#{keyword}\s*\=\s*#{value}(\s+|$)")
            sql.gsub!(regex, " #{keyword} = #{value == 1}\\1")
          end
        end
      end
      sql
    end

    # TODO: optimize this method
    def sql_to_soql(sql)
      # Unescape column and table names
      sql.gsub!('`', '')

      # Remove table namespace from fields
      sql.gsub!("#{QueryBuilder::DUMMY_TABLE_NAME}.", '')

      # Add table name
      sql.gsub!(QueryBuilder::DUMMY_TABLE_NAME, klass.object_name)

      # Convert 1=0 to id IS NULL (id never be NULL, so it a false case)
      sql.gsub!(/\s+1=0(\s*)/i, ' id IS NULL\1')

      # Convert IS NOT to !=
      sql.gsub!(/\s+IS\s+NOT\s+/i, ' != ')

      # Convert IS to =
      sql.gsub!(/\s+IS\s+/i, ' = ')

      # Convert datatime to salesforce format
      sql.gsub!(/'(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2})'/, '\1T\2Z')

      # Convert date to salesforce format
      sql.gsub!(/'(\d{4}-\d{2}-\d{2})'/, '\1')

      # Convert boolean_field = (1|0) to boolean_field = (true|false)
      sql = boolean_data_type_conversion(sql)

      # Convert aliased fields
      convert_aliased_fields(sql)
    end
  end
end
