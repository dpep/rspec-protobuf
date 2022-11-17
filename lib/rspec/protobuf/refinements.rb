module RSpec
  module Protobuf
    module Refinements
      refine Google::Protobuf::MessageExts do
        def include?(*args)
          expected_attrs = Hash === args.last ? args.pop : {}

          # ensure all enumerated keys are present
          return false unless args.all? { |attr| respond_to?(attr) }

          # ensure all enumerated attributes are present
          return false unless expected_attrs.keys.all? { |attr| respond_to?(attr) }

          fields = {}
          self.class.descriptor.each { |f| fields[f.name.to_sym] = f }

          # check expected attribute matches
          expected_attrs.all? do |expected_attr, expected_value|
            field = fields[expected_attr]
            actual_value = field.get(self)

            # convert enum to int value to match input type
            if field.type == :enum && expected_value.is_a?(Integer)
              actual_value = field.subtype.lookup_name(actual_value)
            end

            matches = expected_value === actual_value

            if actual_value.is_a?(Google::Protobuf::MessageExts)
              if expected_value.is_a?(Hash)
                matches ||= actual_value.match?(**expected_value)
              else
                matches ||= expected_value === actual_value.to_h
              end
            end

            matches
          end
        end

        def match?(**attrs)
          # ensure all enumerated keys are present
          return false unless attrs.keys.all? { |attr| respond_to?(attr) }

          # ensure each field matches
          self.class.descriptor.all? do |field|
            actual_value = field.get(self)
            expected_value = attrs[field.name.to_sym]

            if actual_value.is_a?(Google::Protobuf::MessageExts) && expected_value.is_a?(Hash)
              actual_value.match?(**expected_value)
            else
              # fall back to default value
              expected_value = field.default unless attrs.key?(field.name.to_sym)

              # convert enum to int value to match input type
              if field.type == :enum && expected_value.is_a?(Integer)
                actual_value = field.subtype.lookup_name(actual_value)
              end

              expected_value === actual_value
            end
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

            res[field.name.to_sym] = value unless field.default == value
          end

          res
        end
      end
    end
  end
end
