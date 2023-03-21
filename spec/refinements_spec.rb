describe RSpec::Protobuf::Refinements do
  using described_class

  describe "#include?" do
    # redefine matcher in this scope so Refinement can be accessed
    matcher :include_attrs do |attrs|
      match { |msg| msg.include?(attrs) }
    end

    subject do
      ComplexMessage.new(
        # msg: MyMessage.new,
        uid: 123,
        date: DateMessage.new(**date),
      )
    end
    let(:date) { { month: 10, day: 16 } }

    it { is_expected.to include_attrs(:uid) }
    it { is_expected.to include_attrs(:uid, :date) }

    it "includes nil attributes" do
      is_expected.to include_attrs(:msg, :complex, :uuid, :numbers)
    end

    it "does not include bogus attributes" do
      is_expected.not_to include_attrs(:foo)
    end

    it { is_expected.to include_attrs(msg: nil) }
    it { is_expected.to include_attrs(uid: 123) }
    it { is_expected.to include_attrs(uid: Integer) }
    it { is_expected.to include_attrs(uid: 0..200) }

    it { is_expected.to include_attrs(date: date) }
    it { is_expected.to include_attrs(date: hash_including(date)) }
    it { is_expected.to include_attrs(date: include(date)) }

    it { is_expected.to include_attrs(date: include(type: :DATE_DEFAULT)) }
    it { is_expected.not_to include_attrs(date: { type: :DATE_DEFAULT }) }
    it { is_expected.to include_attrs(date: date.merge(type: :DATE_DEFAULT))}

    context "with anything matcher" do
      it { is_expected.to include_attrs(msg: anything) }
      it { is_expected.to include_attrs(uid: anything) }
      it { is_expected.to include_attrs(date: anything) }
      it { is_expected.to include_attrs(date: include(day: anything)) }
    end

    context "with a submessage" do
      subject { ComplexMessage.new(msg: MyMessage.new(msg: "Hello")) }

      it "matches a protobuf" do
        is_expected.to include_attrs(msg: MyMessage.new(msg: "Hello"))
      end

      it "matches a regex" do
        is_expected.to include_attrs(msg: { msg: /^H/ })
      end

      it "matches a symbol" do
        is_expected.to include_attrs(msg: { msg: :Hello })
      end
    end

    context "with enums" do
      subject { DateMessage.new(type: DateType::DATE_BDAY) }

      it { is_expected.to include_attrs(type: :DATE_BDAY) }
      it { is_expected.to include_attrs(type: DateType::DATE_BDAY) }
    end

    it "matches default value for repeated fields" do
      is_expected.to include_attrs(numbers: [])
    end
  end

  describe "#match?" do
    matcher :match_attrs do |**attrs|
      match { |msg| msg.match?(**attrs) }
    end

    subject do
      ComplexMessage.new(
        # msg: MyMessage.new,
        uid: 123,
        date: DateMessage.new(**date),
      )
    end

    let(:date) { { month: 10, day: 16 } }

    it { is_expected.to match_attrs(uid: 123, date: date) }
    it { is_expected.to match_attrs(uid: anything, date: date) }
    it { is_expected.to match_attrs(uid: Integer, date: date) }
    it { is_expected.to match_attrs(uid: 123, date: anything) }
    it { is_expected.to match_attrs(msg: anything, uid: anything, date: anything) }

    it "does not match when attributes are missing" do
      is_expected.not_to match_attrs(uid: 123)
    end

    it "matches when default values are included" do
      is_expected.to match_attrs(
        msg: nil,
        uid: 123,
        date: date.merge(type: :DATE_DEFAULT),
        numbers: [],
      )
    end

    context "with a submessage" do
      subject { ComplexMessage.new(msg: MyMessage.new(msg: "Hello")) }

      it "matches a protobuf" do
        is_expected.to match_attrs(msg: MyMessage.new(msg: "Hello"))
      end

      it "matches a regex" do
        is_expected.to match_attrs(msg: { msg: /^H/ })
      end

      it "matches a symbol" do
        is_expected.to match_attrs(msg: { msg: :Hello })
      end
    end

    it "does not match bogus attributes" do
      is_expected.not_to match_attrs(:foo)
    end

    context "with enums" do
      subject { DateMessage.new(type: DateType::DATE_BDAY) }

      it { is_expected.to match_attrs(type: :DATE_BDAY) }
      it { is_expected.to match_attrs(type: DateType::DATE_BDAY) }
    end
  end

  describe "#normalized_hash" do
    it "discards default values" do
      expect(MyMessage.new.normalized_hash).to eq({})
    end

    it "discards values that match defaults" do
      expect(MyMessage.new(msg: "").normalized_hash).to eq({})
    end

    it "returns non-default attributes" do
      expect(MyMessage.new(msg: "hi").normalized_hash).to eq(msg: "hi")
    end

    it "symbolizes enums" do
      msg = DateMessage.new(type: :DATE_BDAY)
      expect(msg.normalized_hash).to eq(type: :DATE_BDAY)

      msg = DateMessage.new(type: DateType::DATE_BDAY)
      expect(msg.normalized_hash).to eq(type: :DATE_BDAY)
    end

    context "with ComplexMessage" do
      it "discards default values" do
        expect(ComplexMessage.new.normalized_hash).to eq({})
      end

      it "discards values that equal defaults" do
        msg = ComplexMessage.new(
          msg: nil,
          complex: false,
          numbers: [],
        )
        expect(msg.normalized_hash).to eq({})
      end

      it "returns only non-default attributes" do
        msg = ComplexMessage.new(
          msg: MyMessage.new(msg: "woof"),
          uid: 123,
          date: DateMessage.new(month: 10, day: 17),
          numbers: [ 1, 2, 3 ],
        )

        expect(msg.normalized_hash).to eq(
          msg: { msg: "woof" },
          uid: 123,
          date: { month: 10, day: 17 },
          numbers: [ 1, 2, 3 ],
        )
      end

      it "returns empty hashes for all-default sub-messages" do
        msg = ComplexMessage.new(msg: MyMessage.new)

        expect(msg.normalized_hash).to eq(msg: {})
      end

      it "symbolizes enums" do
        msg = ComplexMessage.new(
          date: DateMessage.new(type: :DATE_BDAY),
        )

        expect(msg.normalized_hash).to eq(date: { type: :DATE_BDAY })
      end
    end
  end
end
