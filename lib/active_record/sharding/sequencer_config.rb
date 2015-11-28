module ActiveRecord
  module Sharding
    class SequencerConfig
      attr_reader :name, :table_name, :connection_name

      def initialize(name)
        @name = name
        @table_name = nil
        @connection_name = nil
      end

      def register_connection(connection_name)
        @connection_name = connection_name
      end

      def register_table_name(table_name)
        @table_name = table_name
      end

      def validate_config!
        raise "Nothing connection. Please call register_connection" if @connection_name.blank?
        raise "Nothing table_name. Please call register_table_name" if @table_name.blank?
      end
    end
  end
end
