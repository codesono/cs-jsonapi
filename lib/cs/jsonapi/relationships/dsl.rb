# frozen_string_literal: true

module CS
  module JSONAPI
    module Relationships
      class DSL
        def initialize(&block)
          instance_eval(&block)
        end

        def required(name, type, is_array: false)
          relationship(name, type, required: true, is_array: is_array)
        end

        def optional(name, type, is_array: false)
          relationship(name, type, required: false, is_array: is_array)
        end

        def relationship(name, type, required:, is_array: false)
          raise ArgumentError, "duplicate relationship" if relationships.key? name

          relationships[name] = [type, is_array, required]
        end

        def relationships_schema
          r = relationships

          Dry::Schema.JSON do
            r.each do |name, (_, is_array, required)|
              send(required ? :required : :optional, name).hash do
                if is_array
                  required(:data).array(:hash) do
                    required(:id).filled(:string)
                    required(:type).filled(:string)
                  end
                else
                  required(:data).hash do
                    required(:id).filled(:string)
                    required(:type).filled(:string)
                  end
                end
              end
            end
          end
        end

        def relationship_rules
          relationships.map do |(name, (type, is_array, _))|
            if is_array
              array_relationship_rule(name, type)
            else
              single_relationship_rule(name, type)
            end
          end
        end

        private

        def array_relationship_rule(name, type)
          keys = [{ data: { relationships: { name => :data } } }]
          Dry::Validation::Rule.new(keys: keys, block: nil).each do
            key.path.keys << :type
            key.failure "is invalid" if key? && value[:type].to_s != type.to_s
          end
        end

        def single_relationship_rule(name, type)
          keys = [{ data: { relationships: { name => { data: :type } } } }]
          block = proc {
            key.failure "is invalid" if key? && value.to_s != type.to_s
          }
          Dry::Validation::Rule.new(keys: keys, block: block)
        end

        def relationships
          @relationships ||= {}
        end
      end
    end
  end
end
