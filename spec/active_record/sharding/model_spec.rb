describe ActiveRecord::Sharding::Model do
  before(:all) { ActiveRecord::Base.clear_all_connections! }

  let!(:model) do
    Class.new(ActiveRecord::Base) do
      def self.name
        "User"
      end

      def self.sequence_id
        @sequence_id ||= 0
      end

      class << self
        attr_writer :sequence_id
      end

      def self.next_sequence_id
        self.sequence_id += 1
      end

      include ActiveRecord::Sharding::Model
      use_sharding :user, :modulo
      define_sharding_key :id

      before_put do |attrs|
        attrs[:id] = next_sequence_id unless attrs[:id]
      end

      define_parent_methods do
        def find_from_all_by_name(name)
          all_shards.map { |m| m.find_by(name: name) }.compact.first
        end
      end
    end
  end

  let(:alice) { model.put! name: "Alice" }

  context "ActiveRecord::ConnectionAdapters::ConnectionPool" do
    let(:connection_names) { ["primary", "ShardForTestUser001", "ShardForTestUser002", "ShardForTestUser003", "SequencerForTestUserSequencer"] }

    it "Create 1 connection for each DB" do
      expect(ActiveRecord::Base.connection_handler.connection_pool_list.map{|c| c.spec.name }).to match_array(connection_names)
    end
  end

  describe ".put!" do
    it "example" do
      expect(alice.persisted?).to be true
      expect(alice.name).to eq "Alice"
      expect(alice.class.name).to match(/User::ShardFor/)
    end

    it "raise InvalidPrimaryKey" do
      expect { model.put! id: 0, name: "invalid_id" }.to raise_error ActiveRecord::Sharding::InvalidPrimaryKey
    end

    context "in transaction" do
      it "when rollback" do
        before_record_count = model.all_shards.map(&:count).reduce(:+)

        model.put!(name: "Bob") do |bob|
          expect(bob.persisted?).to be true
          raise ActiveRecord::Rollback
        end

        after_record_count = model.all_shards.map(&:count).reduce(:+)

        expect(after_record_count).to eq before_record_count
      end
    end

    context 'next call #put!' do
      let(:bob) { model.put! name: "Bob" }
      let(:alice_connect_db) { alice.class.connection.pool.spec.config[:database] }
      let(:bob_connect_db) { bob.class.connection.pool.spec.config[:database] }

      it "different connection database" do
        expect(alice_connect_db).not_to eq bob_connect_db
      end
    end

    context "Not included sharding key in args" do
      before do
        allow(User).to receive(:sharding_key).and_return(:dammy_sharding_key)
      end

      it "raise ActiveRecord::Sharding::MissingShardingKeyAttribute" do
        expect do
          User.put! name: "foobar"
        end.to raise_error ActiveRecord::Sharding::MissingShardingKeyAttribute
      end
    end
  end

  describe ".shard_for" do
    before { alice }

    it "example" do
      user_record = model.shard_for(alice.id).find_by name: "Alice"
      expect(user_record).not_to be nil
      expect(user_record.name).to eq "Alice"
    end
  end

  describe ".all_shards_in_parallel" do
    it "returns a ActiveRecord::Sharding::AllShardsInParallel" do
      expect(User.all_shards_in_parallel).to be_a ActiveRecord::Sharding::AllShardsInParallel
    end
  end

  describe ".define_parent_methods" do
    before do
      model.put! name: "foo"
      model.put! name: "bar"
    end

    it "enables to define class methods to parent class" do
      record = model.find_from_all_by_name("foo")
      expect(record).not_to be_nil
      expect(record.name).to eq("foo")
    end
  end

  describe "Irregular use case" do
    context "Not write before_put block" do
      let!(:model) do
        Class.new(ActiveRecord::Base) do
          def self.name
            "User"
          end

          def self.sequence_id
            @sequence_id ||= 0
          end

          class << self
            attr_writer :sequence_id
          end

          def self.next_sequence_id
            self.sequence_id += 1
          end

          include ActiveRecord::Sharding::Model
          use_sharding :user, :modulo
          define_sharding_key :id

          define_parent_methods do
            def find_from_all_by_name(name)
              all_shards.map { |m| m.find_by(name: name) }.compact.first
            end
          end
        end
      end

      it "Raise MissingPrimaryKey at #save" do
        expect { model.shard_for(1).new.save }.to raise_error ActiveRecord::Sharding::MissingPrimaryKey
      end
    end
  end
end
