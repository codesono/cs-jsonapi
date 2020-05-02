# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cs/jsonapi/version"

Gem::Specification.new do |s|
  s.name        = "cs-jsonapi"
  s.version     = CS::JSONAPI::VERSION.dup
  s.summary     = "Tools for using JSON:API with dry-rb and Rails"
  s.description = s.summary
  s.authors     = ["Maciej Mucha"]
  s.email       = "masmoof@gmail.com"
  s.files       = Dir["README.md", "lib/**/*"]
  s.license     = "MIT"

  s.add_runtime_dependency "dry-validation", "~> 1.5"

  s.add_development_dependency "rspec"
end
