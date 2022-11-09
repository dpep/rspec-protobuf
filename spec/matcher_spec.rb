describe :be_a_protobuf do
  subject(:msg) { MyMessage.new(msg: "Hello") }

  it { is_expected.to be_a_protobuf }
  it { is_expected.to be_a_protobuf(MyMessage) }

  it { is_expected.to be_a_protobuf(msg: "Hello") }
  it { is_expected.to be_a_protobuf(msg: /^H/) }
  it { is_expected.to be_a_protobuf(msg: anything) }
  it { is_expected.to be_a_protobuf(msg: include("ll")) }

  describe "composite matching" do
    context "within a hash" do
      subject { { a: 1, b: msg } }

      it { is_expected.to include(b: a_protobuf)}
      it { is_expected.to include(b: a_protobuf(msg: starting_with("H")))}

      it { is_expected.to match(a: Integer, b: a_protobuf)}
    end

    context "within an array" do
      subject { [ 1, msg, Object ] }

      it { is_expected.to include(a_protobuf) }
    end
  end

  context "when it does not match" do
    it { is_expected.not_to be_a_protobuf(msg: "foo") }
    it { is_expected.not_to be_a_protobuf(msg: /f/) }
    it { is_expected.not_to be_a_protobuf(msg: nil) }
    it { is_expected.not_to be_a_protobuf(invalid: true) }
    it { is_expected.not_to be_a_protobuf(DateMessage) }
    it { expect(Object).not_to be_a_protobuf }
    it { expect(123).not_to be_a_protobuf }

    it "produces a failure diff" do
      expect {
        is_expected.to be_a_protobuf(msg: "H")
      }.to fail_including(
        '-:msg => "H",',
        '+:msg => "Hello",'
      )
    end
  end

  context "when input is erroneous" do
    it "catches non-protobuf types" do
      expect {
        is_expected.not_to be_a_protobuf(Object)
      }.to raise_error(TypeError)
    end

    it "catches invalid attributes when proto type is given" do
      expect {
        is_expected.to be_a_protobuf(MyMessage, invalid: true)
      }.to raise_error(ArgumentError)
    end
  end

  context "with a more complex proto" do
    subject(:msg) do
      ComplexMessage.new(
        # msg: MyMessage.new,
        uid: 123,
        date: DateMessage.new(month: 1, day: 3),
      )
    end

    it { is_expected.to be_a_protobuf(msg: nil) }
    it { is_expected.to be_a_protobuf(uid: 0..200) }
    it { is_expected.to be_a_protobuf(date: { month: 1, day: 3 }) }
    it { is_expected.not_to be_a_protobuf(date: { month: 1 }) }
    it { is_expected.to be_a_protobuf(date: include(month: 1)) }
    it { is_expected.to be_a_protobuf(date: include(type: :DATE_DEFAULT)) }

    it "produces a failure diff" do
      expect {
        is_expected.to be_a_protobuf(msg: "H", uid: 1, date: { month: 1 })
      }.to fail_including(
        '-:msg => "H",',

        '-:uid => 1,',
        '+:uid => 123,',

        '-:date => {:month=>1},',
        '+:date => {:day=>3, :month=>1},',
      )
    end
  end
end
