pool = Google::Protobuf::DescriptorPool.new

pool.build do
  add_message "MyMessage" do
    optional :msg, :string, 1
  end

  add_enum "DateType" do
    value :DATE_DEFAULT, 0
    value :DATE_BDAY, 1
  end

  add_message "DateMessage" do
    optional :type, :enum, 1, "DateType"
    optional :month, :int32, 2
    optional :day, :int32, 3
    optional :year, :int32, 4
  end

  add_message "ComplexMessage" do
    optional :msg, :message, 1, "MyMessage"
    optional :complex, :bool, 2
    optional :date, :message, 3, "DateMessage"

    oneof :id do
      optional :uid, :int32, 4
      optional :uuid, :string, 5
    end

    repeated :numbers, :int32, 6
    repeated :messages, :message, 7, "MyMessage"
  end
end

MyMessage = pool.lookup("MyMessage").msgclass
DateType = pool.lookup("DateType").enummodule
DateMessage = pool.lookup("DateMessage").msgclass
ComplexMessage = pool.lookup("ComplexMessage").msgclass
