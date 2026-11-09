require "google/protobuf"
require "rspec/expectations"
require "rspec/protobuf/refinements"
require "rspec/protobuf/version"

using RSpec::Protobuf::Refinements

RSpec::Matchers.define :be_a_protobuf do |type = nil, **attrs|
  match do |actual|
    # ensure type is a valid Protobuf message type
    if type && !(type.is_a?(Class) && type < Google::Protobuf::MessageExts)
      raise TypeError, "Expected arg to be a Google::Protobuf::MessageExts, found: #{type}"
    end

    @fail_msg = "#{actual.inspect} is not a Protobuf"
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

    return true if actual.include?(attrs)

    # let the diff explain: only referenced attrs, defaults removed
    @fail_msg = ""
    @diff_expected = attrs
    @actual = actual.normalized_hash.slice(*attrs.keys)
    false
  end

  # only an attribute mismatch has a useful diff
  def diffable?
    !@diff_expected.nil?
  end

  def expected
    @diff_expected || super
  end

  description do
    type ? "a #{type} Protobuf" : "a Protobuf"
  end

  failure_message { @fail_msg }

  failure_message_when_negated do |actual|
    msg = "expected #{actual} not to be #{description}"
    msg += " with #{attrs}" unless attrs.empty?
    msg
  end
end

RSpec::Matchers.alias_matcher :a_protobuf, :be_a_protobuf
