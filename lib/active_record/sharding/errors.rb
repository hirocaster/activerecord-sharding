module ActiveRecord
  module Sharding
    class Error < ::StandardError
    end

    class MissingShardingKeyAttribute < Error
    end

    class MissingPrimaryKey < Error
    end

    class InvalidSequenceId < Error
    end

    class InvalidPrimaryKey < Error
    end
  end
end
