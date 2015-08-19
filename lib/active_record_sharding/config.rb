module ActiveRecordSharding
  class Config
    def initialize
      @cluster_configs = {}
    end

    def define_cluster(cluster_name, &block)
      cluster_config = ClusterConfig.new(cluster_name)
      cluster_config.instance_eval(&block)
      cluster_config.validate_config!
      @cluster_configs[cluster_name] = cluster_config
    end
  end
end
