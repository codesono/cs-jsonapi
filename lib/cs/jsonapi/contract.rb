# frozen_string_literal: true

require "dry/validation"
require "cs/jsonapi/dsl"
require "pry"

module CS
  module JSONAPI
    class Contract < Dry::Validation::Contract
      class << self
        def jsonapi(&block)
          dsl = DSL.new(&block)

          raise ArgumentError, "resource type is not defined" if dsl.resource_type.nil?

          json do
            required(:data).hash do
              optional(:id).filled(:string)
              required(:type).filled(:string)
              send(dsl.attributes_macro, :attributes).hash(dsl.attributes_schema)
              send(dsl.relationships_macro, :relationships).hash(dsl.relationships_schema)
            end
          end

          rules.concat(dsl.rules)
          rules.concat(dsl.relationship_rules)

          rule(data: :type) { key.failure "invalid type" unless value.to_s == dsl.resource_type.to_s }
        end
      end
    end
  end
end
