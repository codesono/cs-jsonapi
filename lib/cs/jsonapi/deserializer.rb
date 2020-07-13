# frozen_string_literal: true

module CS
  module JSONAPI
    class Deserializer
      attr_reader :data, :only

      def call(data, only: nil)
        attributes = deserialize_resource(data[:data])

        if only.nil?
          attributes
        else
          attributes.slice(*only)
        end
      end

      private

      def deserialize_resource(data)
        relationships = data[:relationships] || {}
        attributes = data[:attributes] || {}

        associations = relationships.each_with_object({}) do |(key, value), hash|
          data = value[:data]

          if data.is_a? Hash
            hash["#{key}_id".to_sym] = value[:data][:id]
          elsif data.respond_to? :[]
            hash["#{key}_ids".to_sym] = value[:data].map { |r| r[:id] }
          else
            raise "Invalid relationships"
          end
        end

        attributes.merge(associations)
      end
    end
  end
end
