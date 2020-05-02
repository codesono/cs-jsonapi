# frozen_string_literal: true

require "cs/jsonapi"

RSpec.describe CS::JSONAPI::Contract do
  subject(:contract) do
    test_class.new
  end

  let(:test_class) do
    Class.new(CS::JSONAPI::Contract) do
      jsonapi do
        type(:resources)

        attributes do
          required(:digit).filled(:integer)
        end

        rule(:digit) do
          key.failure("is not a digit") if value < 0 || value > 9
        end
      end
    end
  end

  it "enforces attribute rules" do
    input = {
      data: {
        type: "resources",
        attributes: {
          digit: 11
        }
      }
    }

    result = contract.call(input)

    expect(result).not_to be_success
    expect(result.errors.to_h).to eq(
      {
        data: {
          attributes: {
            digit: ["is not a digit"]
          }
        }
      }
    )
  end

  it "validates resource type" do
    input = {
      data: {
        type: "notresources",
        attributes: {
          digit: 9
        }
      }
    }

    result = contract.call(input)

    expect(result).not_to be_success
    expect(result.errors.to_h).to eq(
      {
        data: {
          type: ["invalid type"]
        }
      }
    )
  end
end
