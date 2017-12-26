require 'ostruct'
require_relative 'object_maker'

module SalesforceOrm
  class ObjectBase < OpenStruct

    extend ObjectMaker

    class << self

      [
        :create!,
        :update_all!,
        :update_by_id!,
        :destroy_all!,
        :destroy_by_id!,
        :where,
        :select,
        :except,
        :group,
        :order,
        :reorder,
        :limit,
        :offset,
        :first,
        :last,
        :each,
        :scoped,
        :all,
        :to_soql,
        :build
      ].each do |method_name|
        define_method(method_name) do |*args|
          orm.send(method_name, *args)
        end
      end

      def find(*args)
        find_by_id(*args)
      end

      def method_missing(method, *args, &block)
        regex = /^find_by_(.+)$/
        if method =~ regex
          fields = method.to_s.match(regex).captures[0].split('_and_')
          condition = {}
          fields.each_with_index do |field, index|
            condition[field.to_sym] = args[index]
          end
          where(condition).first
        end
      end

      def orm
        Base.new(self)
      end
    end

    [
      :update_attributes!,
      :destroy!
    ].each do |method_name|
      define_method(method_name) do |*args|
        self.class.orm.send(method_name, *([self] + args))
      end
    end

    def to_hash
      to_h
    end

    def inspect
      to_h
    end

    # Fix for unable to cache object of this class.
    # This is a temporary solution. Once Restforce::Mash fix this issue, we'll revert this change
    # WARNING: As of now, you can't do any restforce operation on the object of this class which is fetched from cache
    def marshal_dump
      byebug
      h = to_h
      if h[:attributes]
        h[:attributes] = h[:attributes].clone
        h[:attributes].instance_variable_set(:@client, nil)
      end

      if h[:original_object]
        h[:original_object] = h[:original_object].clone
        h[:original_object].instance_variable_set(:@client, nil)

        if h[:original_object]['attributes']
          h[:original_object]['attributes'] = h[:original_object]['attributes'].clone
          h[:original_object]['attributes'].instance_variable_set(:@client, nil)
        end
      end
      h
    end

    def marshal_load(data)
      result = super(data)

      attributes.instance_variable_set(:@client, RestforceClient.instance) if attributes
      original_object.instance_variable_set(:@client, RestforceClient.instance) if original_object
      original_object.attributes.instance_variable_set(:@client, RestforceClient.instance) if original_object && original_object.attributes

      result
    end
  end
end
