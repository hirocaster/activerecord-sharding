module ActiveRecordSharding
  class ShardRepository
    attr_reader :base_class

    def initialize(cluster_config, base_class)
      @base_class = base_class

      shards = cluster_config.connections.map do |connection_name|
        [connection_name, generate_model_for_shard(connection_name)]
      end

      @shards = Hash[shards]
    end

    def fetch(connection_name)
      @shards.fetch connection_name
    end

    def all
      @shards.values
    end

    private

    def generate_model_for_shard(connection_name)
      base_class_name = @base_class.name
      class_name = generate_class_name connection_name

      model = Class.new(base_class) do
        self.table_name = base_class.table_name

        module_eval <<-RUBY, __FILE__, __LINE__ + 1
                  def self.name
                    "#{base_class_name}::#{class_name}"
                  end
                RUBY
      end

      model.class_eval { establish_connection(connection_name) }
      model
    end

    def generate_class_name(connection_name)
      "ShardFor#{connection_name.to_s.tr('-', '_').classify}"
    end
  end
end
