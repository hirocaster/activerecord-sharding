describe ActiveRecordSharding do
  it 'has a version number' do
    expect(ActiveRecordSharding::VERSION).not_to be nil
  end

  describe ".config" do
    it "returns Config class" do
      expect(ActiveRecordSharding.config).to be_a ActiveRecordSharding::Config
    end

    it "returns equal instance, every call" do
      expect(ActiveRecordSharding.config).to eq ActiveRecordSharding.config
    end
  end
end
