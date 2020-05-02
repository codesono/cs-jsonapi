# frozen_string_literal: true

require "cs/jsonapi/relationships/dsl"

module CS
  module JSONAPI
    class DSL
      def initialize(*args, &block)
        super
        instance_eval(&block)
      end

      def attributes(&block)
        @attributes_schema = Dry::Schema.JSON(&block)
        @attributes_macro = attributes_schema.call({}).success? ? :optional : :required
      end

      def relationships(&block)
        dsl = Relationships::DSL.new(&block)

        @relationships_schema = dsl.relationships_schema
        @relationships_macro = relationships_schema.call({}).success? ? :optional : :required
        @relationship_rules = dsl.relationship_rules
      end

      def rule(keys, &block)
        new_keys = { data: { attributes: keys } }
        rules[new_keys] = block
      end

      def type(type)
        @type ||= type
      end

      def rules
        @rules ||= {}
      end

      def resource_type
        @type
      end

      def attributes_macro
        @attributes_macro || :optional
      end

      def attributes_schema
        @attributes_schema || Dry::Schema.JSON
      end

      def relationship_rules
        @relationship_rules || []
      end

      def relationships_macro
        @relationships_macro || :optional
      end

      def relationships_schema
        @relationships_schema || Dry::Schema.JSON
      end
    end
  end
end
