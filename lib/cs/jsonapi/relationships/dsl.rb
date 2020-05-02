# frozen_string_literal: true

module CS
  module JSONAPI
    module Relationships
      class DSL
        def initialize(&block)
          instance_eval(&block)
        end

        def required(name, type)
          relationship(name, type, true)
        end

        def optional(name, type)
          relationship(name, type, false)
        end

        def relationship(name, type, required)
          raise ArgumentError, "duplicate relationship" if relationships.key? name

          relationships[name] = [type, required]
        end

        def relationships_schema
          r = relationships

          # TODO: array in relationship
          Dry::Schema.JSON do
            r.each do |name, (_, required)|
              send(required ? :required : :optional, name).hash do
                required(:data).hash do
                  required(:id).filled(:string)
                  required(:type).filled(:string)
                end
              end
            end
          end
        end

        def relationship_rules
          relationships.each_with_object({}) do |(name, (type, _)), hash|
            hash[{ data: { relationships: { name => { data: :type } } } }] = proc {
              key.failure "is invalid" if key? && value.to_s != type.to_s
            }
          end
        end

        private

        def relationships
          @relationships ||= {}
        end
      end
    end
  end
end
