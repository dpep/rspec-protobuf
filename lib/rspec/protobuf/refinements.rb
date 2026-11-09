module RSpec
  module Protobuf
    module Refinements
      # Message#to_h, but keeping default-valued fields, which google-protobuf 4 drops
      def self.to_h_with_defaults(value)
        case value
        when Google::Protobuf::MessageExts
          value.class.descriptor.to_h do |field|
            [ field.name.to_sym, to_h_with_defaults(field.get(value)) ]
          end
        when Google::Protobuf::RepeatedField
          value.map { |x| to_h_with_defaults(x) }
        when Google::Protobuf::Map
          # Map#to_h ignores a block
          res = {}
          value.each { |k, v| res[k] = to_h_with_defaults(v) }
          res
        else
          value
        end
      end

      refine Google::Protobuf::MessageExts do
        def include?(*args)
          expected_attrs = Hash === args.last ? args.pop : {}

          # ensure all enumerated keys are indeed attributes
          return false unless args.all? { |attr| field_for(attr) }

          # ensure that expected attribute matches
          expected_attrs.all? do |attr, expected|
            field = field_for(attr)
            field && field_matches?(field, expected)
          end
        end

        def matches?(**attrs)
          # ensure all enumerated attributes are present
          return false unless attrs.keys.all? { |attr| field_for(attr) }

          # ensure that each field matches
          self.class.descriptor.all? do |field|
            field_matches?(field, attrs[field.name.to_sym])
          end
        end

        def normalized_hash
          res = {}

          self.class.descriptor.each do |field|
            value = field.get(self)

            # recursively serialize sub-message
            value = value.normalized_hash if value.is_a?(Google::Protobuf::MessageExts)

            res[field.name.to_sym] = value unless default_value?(field, value)
          end

          res
        end

        private

        # nil unless attr is a Symbol naming a field, not eg. a oneof or method
        def field_for(attr)
          self.class.descriptor.lookup(attr.to_s) if attr.is_a?(Symbol)
        end

        def field_matches?(field, expected)
          actual = field.get(self)

          # mimic protobuf behavior, where nil means the default value
          return default_value?(field, actual) if expected.nil?

          if expected.is_a?(Symbol) && field.type == :string
            # convert symbols to strings
            expected = expected.to_s
          end

          # convert enum to int value to match input type
          if field.type == :enum && expected.is_a?(Integer)
            actual = field.subtype.lookup_name(actual)
          end

          if field.label == :repeated && expected.is_a?(Array)
            return false unless actual.length == expected.length

            actual.zip(expected).all? do |a_actual, a_expected|
              values_match?(a_actual, a_expected)
            end
          else
            values_match?(actual, expected)
          end
        end

        def default_value?(field, value)
          field.label == :repeated ? value.length.zero? : value == field.default
        end

        def values_match?(actual, expected)
          return true if expected === actual

          case actual
          when Google::Protobuf::MessageExts
            return actual.matches?(**expected) if expected.is_a?(Hash)
          when Google::Protobuf::RepeatedField, Google::Protobuf::Map
          else
            return false
          end

          # eg. RSpec matchers, which expect plain Ruby values
          expected === Refinements.to_h_with_defaults(actual)
        end
      end
    end
  end
end
