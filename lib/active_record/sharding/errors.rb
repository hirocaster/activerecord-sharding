module ActiveRecord
  module Sharding
    class Error < ::StandardError
    end

    class MissingShardingKeyAttribute < Error
    end

    class MissingPrimaryKey < Error
    end
  end
end
