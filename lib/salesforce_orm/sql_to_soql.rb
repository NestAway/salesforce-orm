module SalesforceOrm
  module SqlToSoql
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
      convert_aliased_fields(sql).strip
    end
  end
end
