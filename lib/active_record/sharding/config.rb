module ActiveRecord
  module Sharding
    class Config
      attr_reader :cluster_configs, :sequencer_configs

      def initialize
        @cluster_configs = {}
        @sequencer_configs = {}
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

      def define_sequencer(sequencer_name, &block)
        sequencer_config = SequencerConfig.new sequencer_name
        sequencer_config.instance_eval(&block)
        sequencer_config.validate_config!
        @sequencer_configs[sequencer_name] = sequencer_config
      end

      def fetch_sequencer_config(sequencer_name)
        @sequencer_configs.fetch sequencer_name
      end
    end
  end
end
