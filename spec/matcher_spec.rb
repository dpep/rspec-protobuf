describe :be_a_protobuf do
  subject(:msg) { MyMessage.new(msg: "Hello") }

  it { is_expected.to be_a_protobuf }
  it { is_expected.to be_a_protobuf(MyMessage) }

  it { is_expected.to be_a_protobuf(msg: "Hello") }
  it { is_expected.to be_a_protobuf(msg: /^H/) }
  it { is_expected.to be_a_protobuf(msg: anything) }
  it { is_expected.to be_a_protobuf(msg: include("ll")) }

  it "treats strings and symbols as equivalent" do
    is_expected.to be_a_protobuf(msg: :Hello)
  end

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
    it "catches protobuf instance instead of type" do
      expect {
        is_expected.not_to be_a_protobuf(msg)
      }.to raise_error(TypeError)
    end

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
    subject do
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

    it "matches nested protobuf matchers" do
      is_expected.to be_a_protobuf(
        date: a_protobuf(month: 1),
      )
    end

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

  context "with a repeated field of scalars" do
    subject { ComplexMessage.new(numbers: numbers) }
    let(:numbers) { [ 1, 2, 3 ] }

    it { is_expected.to be_a_protobuf(numbers: numbers) }

    it "produces a failure diff" do
      expect {
        is_expected.to be_a_protobuf(numbers: [])
      }.to fail_including(
        '-:numbers => [],',
        '+:numbers => [1, 2, 3],',
      )
    end
  end

  context "with a repeated field of protobufs" do
    subject(:msg) { ComplexMessage.new(messages: messages) }
    let(:messages) do
      [
        MyMessage.new(msg: "a"),
        MyMessage.new(msg: "b"),
        MyMessage.new(msg: "c"),
      ]
    end


    it { is_expected.to be_a_protobuf(**msg.to_h) }
    it { is_expected.to be_a_protobuf(messages: messages) }

    it "matches normalized protobufs" do
      is_expected.to be_a_protobuf(
        messages: [
          { msg: "a" },
          { msg: "b" },
          { msg: "c" },
        ],
      )
    end

    it "matches mixed input" do
      is_expected.to be_a_protobuf(
        messages: [
          MyMessage.new(msg: "a"),
          { msg: "b" },
          include(msg: /^c/),
        ],
      )
    end

    it "catches length mismatches" do
      is_expected.not_to be_a_protobuf(messages: messages[...2])

      expect(
        ComplexMessage.new(messages: messages[...2])
      ).not_to be_a_protobuf(**msg.to_h)
    end

    it "produces a failure diff" do
      expect {
        is_expected.to be_a_protobuf(messages: messages[...2])
      }.to fail_with(
        /\+:messages => \[<MyMessage: msg: "a">, .* "c">\],/,
      )
    end
  end

  context "when expecting a symbol" do
    subject { ComplexMessage.new(msg: MyMessage.new(msg: "hello")) }

    it { is_expected.to be_a_protobuf(msg: { msg: :hello }) }

    it "produces a failure diff that preserves the types" do
      expect {
        is_expected.to be_a_protobuf(msg: { msg: :h })
      }.to fail_including(
        '-:msg => {:msg=>:h},',
        '+:msg => {:msg=>"hello"},',
      )
    end
  end

  describe "default values" do
    subject(:msg) do
      ComplexMessage.new(msg: nil, uid: nil, uuid: nil, numbers: nil)
    end

    it "implicitly converts nil into type-specific default values" do
      is_expected.to eq ComplexMessage.new
    end

    it { expect(msg.msg).to be nil }
    it { expect(msg.uid).to be 0 }
    it { expect(msg.uuid).to eq "" }
    it { expect(msg.numbers).to eq [] }

    it { is_expected.to be_a_protobuf(msg: nil) }

    it { is_expected.to be_a_protobuf(uid: 0) }
    it { is_expected.to be_a_protobuf(uid: nil) }

    it { is_expected.to be_a_protobuf(uuid: "") }
    it { is_expected.to be_a_protobuf(uuid: nil) }

    it { is_expected.to be_a_protobuf(numbers: []) }
    it { is_expected.to be_a_protobuf(numbers: nil) }
  end
end
