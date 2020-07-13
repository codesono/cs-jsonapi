# frozen_string_literal: true

require "cs/jsonapi"

RSpec.describe CS::JSONAPI::Contract do
  subject(:contract) do
    test_class.new
  end

  context "no relationships defined" do
    let(:test_class) do
      Class.new(CS::JSONAPI::Contract) do
        jsonapi do
          type(:resources)
        end
      end
    end

    it "parses JSON:API resource without any relationships" do
      input = {
        data: {
          type: "resources"
        }
      }

      result = contract.call(input)

      expect(result).to be_success
    end

    it "ignores additional relationships" do
      input = {
        data: {
          type: "resources",
          relationships: {
            test: {
              data: {
                type: "tests", id: "test-1d"
              }
            }
          }
        }
      }

      result = contract.call(input)

      expect(result).to be_success

      expect(result.to_h).to eq(
        {
          data: {
            type: "resources",
            relationships: {}
          }
        }
      )
    end
  end

  context "all relationships optional" do
    let(:test_class) do
      Class.new(CS::JSONAPI::Contract) do
        jsonapi do
          type(:resources)

          relationships do
            optional(:test, :tests)
          end
        end
      end
    end

    it "allows for empty relationships" do
      input = {
        data: {
          type: "resources"
        }
      }

      result = contract.call(input)

      expect(result).to be_success
    end
  end

  context "some relationships required" do
    let(:test_class) do
      Class.new(CS::JSONAPI::Contract) do
        jsonapi do
          type(:resources)

          relationships do
            required(:test, :tests)
            optional(:post, :posts)
          end
        end
      end
    end

    it "fails with empty relationships" do
      input = {
        data: {
          type: "resources"
        }
      }

      result = contract.call(input)

      expect(result).not_to be_success
      expect(result.errors.to_h).to eq({ data: { relationships: ["is missing"] } })
    end

    it "fails when relationship type is invalid" do
      input = {
        data: {
          type: "resources",
          relationships: {
            test: {
              data: {
                id: "9d52d4db-2e08-4e7e-975f-c7c8067eb53c",
                type: "nottests"
              }
            }
          }
        }
      }

      result = contract.call(input)

      expect(result).not_to be_success
      expect(result.errors.to_h).to eq({ data: { relationships: { test: { data: { type: ["is invalid"] } } } } })
    end

    it "fails when relationship id is not present" do
      input = {
        data: {
          type: "resources",
          relationships: {
            test: {
              data: {
                type: "tests"
              }
            }
          }
        }
      }

      result = contract.call(input)

      expect(result).not_to be_success
      expect(result.errors.to_h).to eq({ data: { relationships: { test: { data: { id: ["is missing"] } } } } })
    end
  end

  it "raises error on duplicate relationship" do
    expect do
      Class.new(CS::JSONAPI::Contract) do
        jsonapi do
          type(:resources)

          relationships do
            required(:test, :tests)
            optional(:test, :posts)
          end
        end
      end
    end.to raise_error ArgumentError, "duplicate relationship"
  end

  context "array relationships" do
    let(:test_class) do
      Class.new(CS::JSONAPI::Contract) do
        jsonapi do
          type(:resources)
          relationships do
            required(:tests, :tests, is_array: true)
          end
        end
      end
    end

    it "allows for array type relationship" do
      input = {
        data: {
          type: "resources",
          relationships: {
            tests: {
              data: [
                { type: "tests", id: "test-1d" },
                { type: "tests", id: "test-2d" }
              ]
            }
          }
        }
      }

      result = contract.call(input)

      expect(result).to be_success
    end

    it "fails when relationship type is invalid" do
      input = {
        data: {
          type: "resources",
          relationships: {
            tests: {
              data: [
                { type: "not-tests", id: "test-1d" },
                { type: "tests", id: "test-2d" }
              ]
            }
          }
        }
      }

      result = contract.call(input)

      expect(result).not_to be_success
      expect(result.errors.to_h).to eq(
        { data: { relationships: { tests: { data: { 0 => { type: ["is invalid"] } } } } } }
      )
    end
  end
end
