# frozen_string_literal: true

require_relative 'enum/version'

module ND
  module Enum
    class << self
      def nd_enum(db: false, i18n: {}, **configuration)
        set_options(binding)
        enum_module = define_module(@options)

        define_db_enum(db, enum_module) if @options[:db]

        const_set(@options[:attribute].to_s.camelize, enum_module)
      end

      private

      def set_options(caller_binding)
        @options = method(:nd_enum).parameters.each_with_object({}) do |(_, name), options|
          options[name.to_sym] = caller_binding.local_variable_get(name)
        end
        @options[:attribute], @options[:values] = @options.delete(:configuration).to_a.first
        @options[:model] = self
      end

      def define_module(options)
        Module.new do
          include ND::Enum::Base

          # Public methods

          define_singleton_method(:all)     { options[:values] }

          # Private methods

          define_singleton_method(:options) { options }
          options.each_key do |name|
            define_singleton_method(name) { options[name] }
          end

          [:options, *options.keys].each do |method_name|
            singleton_class.class_eval { private method_name.to_sym }
          end

          # Constants

          options[:values].map do |value|
            const_set(value.to_s.upcase, value.to_s)
          end
        end
      end

      def define_db_enum(options, enum_module)
        options = options.is_a?(Hash) ? options : {}
        enum(@attribute => enum_module.to_h, **options)
      end
    end
  end
end
