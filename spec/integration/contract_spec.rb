# frozen_string_literal: true

require "cs/jsonapi"

RSpec.describe CS::JSONAPI::Contract do
  let(:test_class) do
    Class.new(CS::JSONAPI::Contract) do
      jsonapi do
        type(:resources)

        relationships do
          optional(:resource, :resources)
          required(:team, :teams)
        end

        attributes do
          required(:email).filled(:string)
        end
      end
    end
  end

  subject(:contract) do
    test_class.new
  end

  describe "#call" do
    let(:input) do
      {
        data: {
          type: "resources",
          attributes: { email: "zenek.com", unexpected: 1 },
          relationships: {
            team: {
              data: {
                type: "teams",
                id: "id"
              }
            }
          }
        }
      }
    end

    it "returns result as JSON:API compatible structure" do
      result = contract.call(input)

      expect(result).to be_success
    end

    it "returns error when input is invalid" do
      result = contract.call({})

      expect(result).not_to be_success
      expect(result.errors).not_to be_empty
    end
  end

  context "when type is not defined" do
    let(:test_class) do
      Class.new(CS::JSONAPI::Contract) do
        jsonapi do
        end
      end
    end

    it "raises error" do
      expect { contract.call({}) }.to raise_error(ArgumentError, "resource type is not defined")
    end
  end
end
