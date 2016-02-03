require "active_support/concern"
require "expeditor"

module ActiveRecord
  module Sharding
    class AllShardsInParallel
      def initialize(shards)
        @shards = shards
      end

      def map(&_block)
        commands = @shards.map do |model|
          Expeditor::Command.new { model.connection_pool.with_connection { yield model } }
        end
        commands.each(&:start)
        commands.map(&:get)
      end

      def flat_map(&block)
        map(&block).flatten
      end

      def each(&block)
        map(&block) if block_given?
        self
      end
    end
  end
end
