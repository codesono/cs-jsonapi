# frozen_string_literal: true

require "cs/jsonapi"

RSpec.describe CS::JSONAPI::Deserializer do
  subject(:deserializer) { described_class.new }
  let(:data) do
    {
      data: {
        type: "resources",
        attributes: {
          digit: 1
        },
        relationships: {
          account: {
            data: {
              type: "accounts",
              id: "13e6059c-cf43-4486-a849-6dae13243363"
            }
          },
          tags: {
            data: [
              {
                type: "tags",
                id: "tag1"
              },
              {
                type: "tags",
                id: "tag2"
              }
            ]
          }
        }
      }
    }
  end

  it "deserializes JSON:API structure to a flat Hash" do
    expect(deserializer.call(data)).to eq(
      { account_id: "13e6059c-cf43-4486-a849-6dae13243363", digit: 1, tag_ids: %w[tag1 tag2] }
    )
  end

  it "handles attribute whitelist" do
    expect(deserializer.call(data, only: [:digit])).to eq(
      { digit: 1 }
    )
  end
end
