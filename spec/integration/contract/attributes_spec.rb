# frozen_string_literal: true

require "cs/jsonapi"

RSpec.describe CS::JSONAPI::Contract do
  subject(:contract) do
    test_class.new
  end

  context "no attributes defined" do
    let(:test_class) do
      Class.new(CS::JSONAPI::Contract) do
        jsonapi do
          type(:resources)
        end
      end
    end

    it "parses JSON:API resource without any attributes" do
      input = {
        data: {
          type: "resources"
        }
      }

      result = contract.call(input)

      expect(result).to be_success
    end

    it "ignores additional attributes" do
      input = {
        data: {
          type: "resources",
          attributes: {
            name: "John"
          }
        }
      }

      result = contract.call(input)

      expect(result).to be_success

      expect(result.to_h).to eq(
        {
          data: {
            type: "resources",
            attributes: {}
          }
        }
      )
    end
  end

  context "all attributes optional" do
    let(:test_class) do
      Class.new(CS::JSONAPI::Contract) do
        jsonapi do
          type(:resources)

          attributes do
            optional(:email).filled(:string)
          end
        end
      end
    end

    it "allows for empty attributes" do
      input = {
        data: {
          type: "resources"
        }
      }

      result = contract.call(input)

      expect(result).to be_success
    end
  end

  context "some attributes required" do
    let(:test_class) do
      Class.new(CS::JSONAPI::Contract) do
        jsonapi do
          type(:resources)

          attributes do
            required(:name).filled(:string)
            optional(:email).filled(:string)
          end
        end
      end
    end

    it "fails with empty attributes" do
      input = {
        data: {
          type: "resources"
        }
      }

      result = contract.call(input)

      expect(result).not_to be_success
    end
  end
end
