module ActiveRecord
  module Sharding
    class ShardRepository < AbstractRepository
      attr_reader :base_class

      def initialize(cluster_config, base_class)
        @base_class = base_class

        shards = cluster_config.connections.map do |connection_name|
          [connection_name, generate_model_for_shard(connection_name)]
        end

        @shards = Hash[shards]
      end

      def fetch(connection_name)
        @shards.fetch connection_name
      end

      def all
        @shards.values
      end

      private

        def generate_class_name(connection_name)
          "ShardFor#{connection_name.to_s.tr('-', '_').classify}"
        end
    end
  end
end
