describe ActiveRecordSharding::ShardRepository do
  let(:cluster_config) { ActiveRecordSharding.config.fetch_cluster_config(:user) }
  let(:shard_repository) { described_class.new cluster_config, User }

  describe '#fetch' do
    it 'returns User class base shard object' do
      expect(shard_repository.fetch(:test_user_001).connection).to be_a ActiveRecord::ConnectionAdapters::AbstractAdapter
      expect(shard_repository.fetch(:test_user_001).table_name).to eq 'users'
      expect(shard_repository.fetch(:test_user_001).name).to eq 'User::ShardForTestUser001'
    end
  end

  describe '#all' do
    it 'returns all shard class objects' do
      expect(shard_repository.all.count).to eq 3
      expect(shard_repository.all[0]).to eq shard_repository.fetch(:test_user_001)
      expect(shard_repository.all[1]).to eq shard_repository.fetch(:test_user_002)
      expect(shard_repository.all[2]).to eq shard_repository.fetch(:test_user_003)
    end
  end
end
