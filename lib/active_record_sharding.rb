require "active_record_sharding/version"
require "active_record_sharding/errors"
require "active_record_sharding/config"
require "active_record_sharding/cluster_config"

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
