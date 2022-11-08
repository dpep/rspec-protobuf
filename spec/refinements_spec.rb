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
      is_expected.to include_attrs(:msg, :complex)
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

    it "supports regex matching" do
      msg = ComplexMessage.new(msg: MyMessage.new(msg: "Hi"))
      expect(msg).to include_attrs(msg: { msg: /^H/ })
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
      )
    end

    it "supports regex matching" do
      expect(MyMessage.new(msg: "Hi")).to match_attrs(msg: /^H/)
    end

    it "does not match bogus attributes" do
      is_expected.not_to match_attrs(:foo)
    end
  end
end
