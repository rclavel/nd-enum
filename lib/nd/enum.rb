# frozen_string_literal: true

require 'active_record'
require 'active_record/enum.rb'

require 'active_support'
require 'active_support/core_ext/string/inflections.rb'

require_relative 'enum/version'
require_relative 'enum/base'

module ND
  module Enum
    extend ActiveSupport::Concern

    included do
      def self.nd_enum(db: false, i18n: {}, **configuration)
        options = ND::Enum.set_options(binding, self)
        enum_module = ND::Enum.define_module(options)

        ND::Enum.define_db_enum(options, enum_module) if options[:db]

        const_set(options[:attribute].to_s.camelize, enum_module)
      end
    end

    class << self
      def set_options(caller_binding, caller_class)
        options = caller_class.method(:nd_enum).parameters.each_with_object({}) do |(_, name), options|
          options[name.to_sym] = caller_binding.local_variable_get(name)
        end
        options[:attribute], options[:values] = options.delete(:configuration).to_a.first
        options[:model] = caller_class

        options
      end

      def define_module(options)
        Module.new do
          include ND::Enum::Base

          # Public methods

          define_singleton_method(:all) { options[:values] }

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
        enum_options = options[:db].is_a?(Hash) ? options[:db] : {}

        enum_options[:_prefix] = enum_options.delete(:prefix) if enum_options.key?(:prefix)
        enum_options[:_suffix] = enum_options.delete(:suffix) if enum_options.key?(:suffix)

        options[:model].enum(options[:attribute] => enum_module.to_h, **enum_options)
      end
    end
  end
end

class ActiveRecord::Base
  include ND::Enum
end
