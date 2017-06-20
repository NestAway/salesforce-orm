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
  end
end
