module ActiveRecordSharding
  class SequencerRepository
    attr_reader :base_class

    def initialize(sequencer_config, base_class)
      @base_class = base_class
      @sequencer = { sequencer_config.name => generate_model_for_shard(sequencer_config.connection_name) }
    end

    def fetch(connection_name)
      @sequencer.fetch connection_name
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
      "SequencerFor#{connection_name.to_s.tr('-', '_').classify}"
    end
  end
end
