describe ActiveRecord::Sharding::Model do
  let!(:model) do
    Class.new(ActiveRecord::Base) do
      def self.name
        'User'
      end

      include ActiveRecord::Sharding::Sequencer
      use_sequencer :user
    end
  end

  describe '#current_sequence_id' do
    it 'returns current sequence id' do
      expect(model.current_sequence_id).to be_a_kind_of Fixnum
    end
  end
  describe '#next_sequence_id' do
    let(:current_id) { model.current_sequence_id }
    let(:next_id) { model.next_sequence_id }

    it 'returns next sequence id' do
      expect(current_id + 1).to eq next_id
      expect(next_id).to be_a_kind_of Fixnum
    end

    it 'next sequence id > current sequence id' do
      expect(current_id).to be < next_id
    end
  end
end
