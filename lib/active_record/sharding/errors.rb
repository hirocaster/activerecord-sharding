module ActiveRecord
  module Sharding
    class Error < ::StandardError
    end

    class MissingShardingKeyAttribute < Error
    end
  end
end
