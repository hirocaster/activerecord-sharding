describe ActiveRecord::Sharding::Facade do
  let!(:model) do
    Class.new(ActiveRecord::Base) do
      def self.name
        "User"
      end

      include ActiveRecord::Sharding::Facade

      use_sharding :user, :modulo
      define_sharding_key :id
      use_sequencer :user
    end
  end

  describe "including modules" do
    it "includes ActiveRecord::Sharding::Model and ActiveRecord::Sharding::Sequencer" do
      expect(model).to be_include ActiveRecord::Sharding::Model
      expect(model).to be_include ActiveRecord::Sharding::Sequencer
    end
  end

  shared_examples_for "successfully" do
    it "inserts a record" do
      expect(alice.persisted?).to be true
      expect(alice.id).to eq model.current_sequence_id
      expect(alice.name).to eq "Alice"
      expect(alice.class.name).to match /User::ShardFor/
    end
  end

  describe ".put!" do
    let(:alice) { model.put!(name: "Alice") }

    it_behaves_like "successfully"
  end

  describe ".new and #save" do
    let(:alice) do
      alice = model.shard_for(1).new(name: "Alice")
      alice.save
      alice
    end

    it_behaves_like "successfully"
  end
end
