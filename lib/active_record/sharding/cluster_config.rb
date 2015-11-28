module ActiveRecord
  module Sharding
    class ClusterConfig
      attr_reader :name

      def initialize(name)
        @name = name
        @connection_registry = []
      end

      def register_connection(connection_name)
        @connection_registry << connection_name
      end

      def fetch(modulo_key)
        @connection_registry[modulo_key]
      end

      def registerd_connection_count
        @connection_registry.count
      end

      def validate_config!
        raise "Nothing registerd connections." if registerd_connection_count == 0
      end

      def connections
        @connection_registry
      end
    end
  end
end
