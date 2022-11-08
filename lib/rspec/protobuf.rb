require "google/protobuf"
require "rspec"
require "rspec/protobuf/refinements"
require "rspec/protobuf/version"

using RSpec::Protobuf::Refinements

RSpec::Matchers.define :be_a_protobuf do |type = nil, **attrs|
  match do |actual|
    # ensure type is a valid Protobuf message type
    if type && !(type < Google::Protobuf::MessageExts)
      raise TypeError, "Expected areg to be a Google::Protobuf::MessageExts, found: #{type}"
    end

    return false unless actual.is_a?(Google::Protobuf::MessageExts)

    # match expected message type
    @fail_msg = "Expected a Protobuf message of type #{type}, found #{actual.class}"
    return false if type && actual.class != type

    return true if attrs.empty?

    if type
      # validate attrs
      invalid_attrs = attrs.keys - type.descriptor.map { |x| x.name.to_sym }

      unless invalid_attrs.empty?
        raise ArgumentError, "invalid attribute for #{type}: #{invalid_attrs.join(", ")}"
      end
    end

    actual.include?(attrs)
  end

  description do
    type ? "a #{type} Protobuf message" : "a Protobuf message"
  end

  failure_message { @fail_msg }
end

RSpec::Matchers.alias_matcher :a_protobuf, :be_a_protobuf
