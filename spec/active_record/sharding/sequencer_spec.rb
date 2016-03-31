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

  let(:sequencer_args) do
    { sequencer_name: "user" }
  end

  context "forget insert sequencer record" do
    before do
      ActiveRecord::Sharding::DatabaseTasks.drop_sequencer_database sequencer_args
      ActiveRecord::Sharding::DatabaseTasks.create_sequencer_database sequencer_args
      ActiveRecord::Sharding::DatabaseTasks.create_table_sequencer_database sequencer_args
    end

    after do
      ActiveRecord::Sharding::DatabaseTasks.insert_initial_record_sequencer_database sequencer_args # forget this in setup
    end

    it "raise ActiveRecord::Sharding::InvalidSequenceId" do
      expect { model.next_sequence_id }.to raise_error ActiveRecord::Sharding::InvalidSequenceId
    end
  end

  describe '#current_sequence_id' do
    it "returns current sequence id" do
      current_id = model.current_sequence_id
      expect(current_id).to be_a_kind_of Fixnum
      expect(model.current_sequence_id).to eq current_id
    end

    it "output class name to log" do
      sequencer_klass = model.sequencer_repository.fetch(:user)
      expect(sequencer_klass.connection).to receive(:execute).with(anything, "User::SequencerForTestUserSequencer").and_return([[0]]).twice
      model.current_sequence_id
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

    context "when offset is selected" do
      let(:offset) { 10 }

      it "returns current_sequence_id with offset" do
        next_id = model.current_sequence_id + offset
        expect(next_id).to eq model.next_sequence_id(offset)
        expect(next_id).to eq model.current_sequence_id
      end

      context "when negative number in offset args" do
        let(:offset) { -5 }

        it "raise error" do
          expect { model.next_sequence_id offset }.to raise_error ActiveRecord::Sharding::Sequencer::NegativeNumberOffsetError
        end
      end
    end
  end
end
