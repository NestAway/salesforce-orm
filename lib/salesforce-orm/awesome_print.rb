module SalesforceOrm
  module AwesomePrint
    def self.included(base)
      base.send :alias_method, :cast_without_salesforce_orm_base, :cast
      base.send :alias_method, :cast, :cast_with_salesforce_orm_base
    end

    def cast_with_salesforce_orm_base(object, type)
      cast = cast_without_salesforce_orm_base(object, type)
      if (defined?(Base)) && (object.is_a?(Base))
        cast = :array
      end
      cast
    end
  end

  if defined?(::AwesomePrint::Formatter)
    ::AwesomePrint::Formatter.send(:include, AwesomePrint)
  end
end
