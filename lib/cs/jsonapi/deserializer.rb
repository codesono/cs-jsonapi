# frozen_string_literal: true

module CS
  module JSONAPI
    class Deserializer
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def call
        deserialize_resource(data[:data])
      end

      private

      def deserialize_resource(data)
        relationships = data[:relationships] || {}
        attributes = data[:attributes] || {}

        # TODO: handle multiple resources in association
        associations = relationships.each_with_object({}) do |(key, value), hash|
          hash["#{key}_id".to_sym] = value[:data][:id]
        end

        attributes.merge(associations)
      end
    end
  end
end
