module ActiveRecordSharding
  class Config
    attr_reader :cluster_configs

    def initialize
      @cluster_configs = {}
    end

    def define_cluster(cluster_name, &block)
      cluster_config = ClusterConfig.new(cluster_name)
      cluster_config.instance_eval(&block)
      cluster_config.validate_config!
      @cluster_configs[cluster_name] = cluster_config
    end

    def fetch_cluster_config(cluster_name)
      @cluster_configs.fetch cluster_name
    end
  end
end
