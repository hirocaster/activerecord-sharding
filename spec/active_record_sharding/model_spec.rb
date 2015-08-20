describe ActiveRecordSharding::Model do
  let!(:model) do
    Class.new(ActiveRecord::Base) do
      def self.name
        'User'
      end

      def self.sequence_id
        @sequence_id ||= 0
      end

      def self.sequence_id=(value)
        @sequence_id = value
      end

      def self.next_sequence_id
        self.sequence_id += 1
      end

      include ActiveRecordSharding::Model
      use_sharding :user
      define_sharding_key :id

      before_put do |attrs|
        attrs[:id] = next_sequence_id unless attrs[:id]
      end

      define_parent_methods do
        def find_from_all_by_name(name)
          all_shards.map {|m| m.find_by(name: name) }.compact.first
        end
      end
    end
  end

  let(:alice) { model.put! name: 'Alice' }

  describe '.put!' do
    it 'example' do
      expect(alice.persisted?).to be true
      expect(alice.name).to eq 'Alice'
      expect(alice.class.name).to match %r{User::ShardFor}
    end

    context 'next call #put!' do
      let(:bob) { model.put! name: 'Bob' }
      let(:alice_connect_db) { alice.class.connection.pool.spec.config[:database] }
      let(:bob_connect_db) { bob.class.connection.pool.spec.config[:database] }

      it 'different connection database' do
        expect(alice_connect_db).not_to eq bob_connect_db
      end
    end

    context 'Not included sharding key in args' do
      before do
        allow(User).to receive(:sharding_key).and_return(:dammy_sharding_key)
      end

      it 'raise ActiveRecordSharding::MissingShardingKeyAttribute' do
        expect do
          User.put! name: 'foobar'
        end.to raise_error ActiveRecordSharding::MissingShardingKeyAttribute
      end
    end
  end

  describe '.shard_for' do
    before { alice }

    it 'example' do
      user_record = model.shard_for(alice.id).find_by name: 'Alice'
      expect(user_record).not_to be nil
      expect(user_record.name).to eq 'Alice'
    end
  end

  describe '.define_parent_methods' do
    before do
      model.put! name: 'foo'
      model.put! name: 'bar'
    end

    it 'enables to define class methods to parent class' do
      record = model.find_from_all_by_name('foo')
      expect(record).not_to be_nil
      expect(record.name).to eq('foo')
    end
  end
end
