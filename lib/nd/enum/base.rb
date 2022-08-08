# frozen_string_literal: true

module ND
  module Base
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

        # TODO: Warning if not defined
        # `t(:foo)`
        # fr:
        #   table_name:
        #     attribute:
        #       base:
        #         foo: Foo
        #
        # or
        #
        # `t(:foo, :scope_a)`
        # fr:
        #   table_name:
        #     attribute:
        #       base:
        #         foo: Foo
        #       scope_a:
        #         foo: Foo A
        #       scope_b:
        #         foo: Foo B
        def t(value, scope = :base)
          I18n.t(value, scope: "#{model.table_name}.#{attribute}.#{scope}")
        end
      end
    end
  end
end
