require_relative "lib/rspec/protobuf/version"

Gem::Specification.new do |s|
  s.name        = "rspec-protobuf"
  s.version     = RSpec::Protobuf::VERSION
  s.authors     = ["Daniel Pepper"]
  s.summary     = "RSpec::Protobuf"
  s.description = "RSpec matchers for Protobuf"
  s.homepage    = "https://github.com/dpep/rspec-protobuf"
  s.license     = "MIT"
  s.files       = `git ls-files * ':!:spec'`.split("\n")

  s.required_ruby_version = ">= 3.3"

  s.add_dependency "google-protobuf", ">= 3"
  s.add_dependency "rspec-expectations", ">= 3"

  s.add_development_dependency "debug"
  s.add_development_dependency "rspec", ">= 3"
  s.add_development_dependency "simplecov"
end
