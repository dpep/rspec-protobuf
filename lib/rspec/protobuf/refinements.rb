module RSpec
  module Protobuf
    module Refinements
      refine Google::Protobuf::MessageExts do
        def include?(*args)
          expected_attrs = Hash === args.last ? args.pop : {}

          # ensure all enumerated keys are indeed attributes
          return false unless args.all? { |attr| respond_to?(attr) }

          # ensure all enumerated attributes are present
          return false unless expected_attrs.keys.all? { |attr| respond_to?(attr) }

          fields = Hash[
            self.class.descriptor.map { |f| [ f.name.to_sym, f ] }
          ]

          # ensure that expected attribute matches
          expected_attrs.all? do |expected_attr, expected_value|
            field_matches?(fields[expected_attr], expected_value)
          end
        end

        def matches?(**attrs)
          # ensure all enumerated attributes are present
          return false unless attrs.keys.all? { |attr| respond_to?(attr) }

          # ensure that each field matches
          self.class.descriptor.all? do |field|
            field_matches?(field, attrs[field.name.to_sym])
          end
        end

        def normalized_hash
          res = {}

          self.class.descriptor.each do |field|
            value = field.get(self)

            if value.is_a?(Google::Protobuf::MessageExts)
              # recursively serialize sub-message
              value = value.normalized_hash
            end

            default = field.label == :repeated ? [] : field.default
            res[field.name.to_sym] = value unless default == value
          end

          res
        end

        private

        def field_matches?(field, expected)
          actual = field.get(self)

          if expected.nil?
            # mimic protobuf behavior and convert to default value
            expected = field.label == :repeated ? [] : field.default
          elsif expected.is_a?(Symbol) && field.type == :string
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

        def values_match?(actual, expected)
          if actual.is_a?(Google::Protobuf::MessageExts)
            case expected
            when Google::Protobuf::MessageExts
              expected === actual
            when Hash
              # recurse
              actual.matches?(**expected)
            else
              # eg. RSpec matchers
              expected === actual.to_h
            end
          else
            expected === actual
          end
        end
      end
    end
  end
end
