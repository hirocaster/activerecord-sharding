describe ActiveRecord::Sharding::ClusterConfig do
  let(:config) { described_class.new(:user) }

  it "returns cluster config name" do
    expect(config.name).to eq :user
  end

  describe '#register_connection' do
    let(:db_connection_001) { :production_user_001 }
    let(:db_connection_002) { :production_user_002 }
    let(:db_connection_003) { :production_user_003 }

    before do
      config.register_connection :db_connection_001
      config.register_connection :db_connection_002
      config.register_connection :db_connection_003
    end

    describe '#registerd_connection_count' do
      it "returns registerd total connection count" do
        expect(config.registerd_connection_count).to eq 3
      end
    end

    describe '#fetch' do
      it "returns database connection name by modulo number" do
        expect(config.fetch 0).to eq :db_connection_001
        expect(config.fetch 1).to eq :db_connection_002
        expect(config.fetch 2).to eq :db_connection_003
      end
    end
  end

  describe '#validate_config!' do
    context "Nothing register connection" do
      it "returns raise" do
        expect { config.validate_config! }.to raise_error "Nothing registerd connections."
      end
    end
  end
end
