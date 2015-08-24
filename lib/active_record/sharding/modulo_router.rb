module ActiveRecord
  module Sharding
    class ModuloRouter
      def initialize(cluster_config)
        @cluster_config = cluster_config
      end

      def route(id)
        modulo_key = id % @cluster_config.registerd_connection_count
        @cluster_config.fetch modulo_key
      end
    end
  end
end
