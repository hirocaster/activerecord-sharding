describe ActiveRecord::Sharding::Model do
  let!(:model) do
    Class.new(ActiveRecord::Base) do
      def self.name
        "User"
      end

      include ActiveRecord::Sharding::Sequencer
      use_sequencer :user
    end
  end

  describe '#current_sequence_id' do
    it "returns current sequence id" do
      current_id = model.current_sequence_id
      expect(current_id).to be_a_kind_of Fixnum
      expect(model.current_sequence_id).to eq current_id
    end
  end

  describe '#next_sequence_id' do
    it "returns next sequence id" do
      next_id = model.current_sequence_id + 1
      expect(next_id).to eq model.next_sequence_id
      expect(next_id).to eq model.current_sequence_id
    end

    it "next sequence id > current sequence id" do
      expect(model.current_sequence_id).to be < model.next_sequence_id
    end
  end
end
