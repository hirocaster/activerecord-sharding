module ActiveRecordSharding
  class Error < ::StandardError
  end

  class MissingShardingKeyAttribute < Error
  end
end
