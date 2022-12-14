# frozen_string_literal: true

require 'forwardable'
require 'active_support'

module ND::Enum::Base
  extend ActiveSupport::Concern

  included do
    class << self
      include Enumerable
      extend Forwardable

      def_delegators :all, :size, :length, :[], :empty?, :last, :index

      def each(&block)
        all.each(&block)
      end

      def to_h
        all.map { |value| [value.to_sym, value] }.to_h
      end

      def [](value)
        value.is_a?(Integer) ? all[value] : to_h[value.to_sym]
      end

      def t(value, scope = nil)
        scope ||= configuration.default_i18n_scope
        ::I18n.t(value, scope: "#{model.table_name}.#{attribute}.#{scope}")
      end
      alias_method :translate, :t

      private

      def configuration
        ND::Enum.configuration
      end
    end
  end
end
