# cs-jsonapi
![CI Status](https://github.com/codesono/cs-jsonapi/workflows/Run%20linter%20and%20tests/badge.svg?branch=master)

Tools for using JSON:API with dry-rb and Rails

## CS::JSONAPI::Deserializer
Converts JSON:API structure to a flat `Hash` of attributes that can be passed for example to ActiveRecord.

```ruby
require "cs/jsonapi"

jsonapi_data = {
  data: {
    type: "digits",
    attributes: {
      digit: 1
    },
    relationships: {
      account: {
        data: {
          type: "accounts",
          id: "13e6059c-cf43-4486-a849-6dae13243363"
        }
      }
    }
  }
}
attributes = CS::JSONAPI::Deserializer.new.call(jsonapi_data)
# {:digit=>1, :account_id=>"13e6059c-cf43-4486-a849-6dae13243363"}
filtered_attributes = CS::JSONAPI::Deserializer.new.call(jsonapi_data, only: [:digit])
# {:digit=>1}
Digit.create(filtered_attributes)
```

## CS::JSONAPI::Contract
DSL on top of `dry-validation` for defining JSON:API validations.
```ruby
require "cs/jsonapi"

class Digit < CS::JSONAPI::Contract
  jsonapi do
    type(:digits)

    attributes do
      # attribute definitions
      required(:digit).filled(:integer)
    end

    # rules for attribute validations
    rule(:digit) do
      key.failure("is not a digit") if value < 0 || value > 9
    end

    # relationships
    relationships do
      optional(:user, :users)
      required(:account, :accounts)
    end
  end
end

jsonapi_data = {
  data: {
    type: "digits",
    attributes: {
      digit: 1,
      unexpected: false
    },
    relationships: {
      account: {
        data: {
          type: "accounts",
          id: "13e6059c-cf43-4486-a849-6dae13243363"
        }
      }
    }
  }
}

p Digit.new.call(jsonapi_data)
# :data => {
#   :type => "digits",
#     :attributes => {
#       :digit=>1
#     },
#     :relationships => {
#       :account => {
#         :data => {
#           :id => "13e6059c-cf43-4486-a849-6dae13243363",
#           :type => "accounts"
#         }
#       }
#     }
#   }
# }
```
