describe ActiveRecordSharding::ModuloRouter do
  let(:cluster_config) do
    cluster_config = ActiveRecordSharding::ClusterConfig.new :user
    cluster_config.register_connection :db_connection_001
    cluster_config.register_connection :db_connection_002
    cluster_config.register_connection :db_connection_003
    cluster_config
  end

  let(:router) { described_class.new cluster_config }

  describe "#route" do
    it "returns database connection name by id % cluster nodes" do
      expect(router.route(1)).to eq :db_connection_002
      expect(router.route(2)).to eq :db_connection_003
      expect(router.route(3)).to eq :db_connection_001
      expect(router.route(4)).to eq :db_connection_002
      expect(router.route(5)).to eq :db_connection_003
      expect(router.route(6)).to eq :db_connection_001
    end
  end
end
