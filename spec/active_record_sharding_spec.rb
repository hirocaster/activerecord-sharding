describe ActiveRecord::Sharding do
  it "has a version number" do
    expect(ActiveRecord::Sharding::VERSION).not_to be nil
  end

  describe ".config" do
    it "returns Config class" do
      expect(ActiveRecord::Sharding.config).to be_a ActiveRecord::Sharding::Config
    end

    it "returns equal instance, every call" do
      expect(ActiveRecord::Sharding.config).to eq ActiveRecord::Sharding.config
    end
  end
end
