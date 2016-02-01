require "active_record"

require "active_record/sharding/version"
require "active_record/sharding/errors"
require "active_record/sharding/config"
require "active_record/sharding/cluster_config"
require "active_record/sharding/modulo_router"
require "active_record/sharding/abstract_repository"
require "active_record/sharding/shard_repository"
require "active_record/sharding/database_tasks"
require "active_record/sharding/all_shards_in_parallel"
require "active_record/sharding/model"
require "active_record/sharding/sequencer"
require "active_record/sharding/sequencer_repository"
require "active_record/sharding/sequencer_config"

module ActiveRecord
  module Sharding
    class << self
      def config
        @config ||= Config.new
      end

      def configure(&block)
        config.instance_eval(&block)
      end
    end
  end
end

require "active_record/sharding/railtie" if defined? Rails
