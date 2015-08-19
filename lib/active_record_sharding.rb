require "active_record"

require "active_record_sharding/version"
require "active_record_sharding/errors"
require "active_record_sharding/config"
require "active_record_sharding/cluster_config"
require "active_record_sharding/modulo_router"
require "active_record_sharding/shard_repository"
require "active_record_sharding/database_tasks"

module ActiveRecordSharding
  class << self
    def config
      @config ||= Config.new
    end

    def configure(&block)
      config.instance_eval(&block)
    end
  end
end
