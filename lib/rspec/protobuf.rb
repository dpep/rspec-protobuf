require "google/protobuf"
require "rspec"
require "rspec/protobuf/refinements"
require "rspec/protobuf/version"

using RSpec::Protobuf::Refinements

RSpec::Matchers.define :be_a_protobuf do |type = nil, **attrs|
  match do |actual|
    # ensure type is a valid Protobuf message type
    if type && !(type < Google::Protobuf::MessageExts)
      raise TypeError, "Expected arg to be a Google::Protobuf::MessageExts, found: #{type}"
    end

    @fail_msg = "#{actual} is not a Protobuf"
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

    @fail_msg = ""

    # customize differ output by removing unreferenced and default attrs
    @actual = actual.normalized_hash.slice(*attrs.keys).reject do |k, v|
      v == actual.class.descriptor.lookup(k.to_s).default
    end

    actual.include?(attrs)
  end

  description do
    type ? "a #{type} Protobuf" : "a Protobuf"
  end

  failure_message { @fail_msg }

  diffable
end

RSpec::Matchers.alias_matcher :a_protobuf, :be_a_protobuf
