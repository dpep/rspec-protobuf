require "google/protobuf/descriptor_pb"

pool = Google::Protobuf::DescriptorPool.new

file = Google::Protobuf::FileDescriptorProto.new(
  name: "spec_messages.proto",
  syntax: "proto2",
  enum_type: [
    Google::Protobuf::EnumDescriptorProto.new(
      name: "DateType",
      value: [
        Google::Protobuf::EnumValueDescriptorProto.new(name: "DATE_DEFAULT", number: 0),
        Google::Protobuf::EnumValueDescriptorProto.new(name: "DATE_BDAY", number: 1),
      ],
    ),
  ],
  message_type: [
    Google::Protobuf::DescriptorProto.new(
      name: "MyMessage",
      field: [
        Google::Protobuf::FieldDescriptorProto.new(
          name: "msg",
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
        ),
      ],
    ),
    Google::Protobuf::DescriptorProto.new(
      name: "DateMessage",
      field: [
        Google::Protobuf::FieldDescriptorProto.new(name: "type", number: 1, label: :LABEL_OPTIONAL, type: :TYPE_ENUM, type_name: "DateType"),
        Google::Protobuf::FieldDescriptorProto.new(name: "month", number: 2, label: :LABEL_OPTIONAL, type: :TYPE_INT32),
        Google::Protobuf::FieldDescriptorProto.new(name: "day", number: 3, label: :LABEL_OPTIONAL, type: :TYPE_INT32),
        Google::Protobuf::FieldDescriptorProto.new(name: "year", number: 4, label: :LABEL_OPTIONAL, type: :TYPE_INT32),
      ],
    ),
    Google::Protobuf::DescriptorProto.new(
      name: "ComplexMessage",
      oneof_decl: [
        Google::Protobuf::OneofDescriptorProto.new(name: "id"),
      ],
      field: [
        Google::Protobuf::FieldDescriptorProto.new(name: "msg", number: 1, label: :LABEL_OPTIONAL, type: :TYPE_MESSAGE, type_name: "MyMessage"),
        Google::Protobuf::FieldDescriptorProto.new(name: "complex", number: 2, label: :LABEL_OPTIONAL, type: :TYPE_BOOL),
        Google::Protobuf::FieldDescriptorProto.new(name: "date", number: 3, label: :LABEL_OPTIONAL, type: :TYPE_MESSAGE, type_name: "DateMessage"),
        Google::Protobuf::FieldDescriptorProto.new(name: "uid", number: 4, label: :LABEL_OPTIONAL, type: :TYPE_INT32, oneof_index: 0),
        Google::Protobuf::FieldDescriptorProto.new(name: "uuid", number: 5, label: :LABEL_OPTIONAL, type: :TYPE_STRING, oneof_index: 0),
        Google::Protobuf::FieldDescriptorProto.new(name: "numbers", number: 6, label: :LABEL_REPEATED, type: :TYPE_INT32),
        Google::Protobuf::FieldDescriptorProto.new(name: "messages", number: 7, label: :LABEL_REPEATED, type: :TYPE_MESSAGE, type_name: "MyMessage"),
      ],
    ),
  ],
)

pool.add_serialized_file(Google::Protobuf::FileDescriptorProto.encode(file))

MyMessage = pool.lookup("MyMessage").msgclass
DateType = pool.lookup("DateType").enummodule
DateMessage = pool.lookup("DateMessage").msgclass
ComplexMessage = pool.lookup("ComplexMessage").msgclass
