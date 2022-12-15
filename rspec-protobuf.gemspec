package_name = File.basename(__FILE__).split(".")[0]
load Dir.glob("lib/**/version.rb")[0]

package = RSpec::Protobuf


Gem::Specification.new do |s|
  s.name        = package_name
  s.version     = package.const_get "VERSION"
  s.authors     = ["Daniel Pepper"]
  s.summary     = package.to_s
  s.description = "RSpec matchers for Protobuf"
  s.homepage    = "https://github.com/dpep/#{package_name}"
  s.license     = "MIT"
  s.files       = `git ls-files * ':!:spec'`.split("\n")

  s.add_dependency "google-protobuf", ">= 3"
  s.add_dependency "rspec-expectations", ">= 3"

  s.add_development_dependency "byebug"
  s.add_development_dependency "codecov"
  s.add_development_dependency "rspec", ">= 3"
  s.add_development_dependency "simplecov"
end
