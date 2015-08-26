module ActiveRecord
  module Sharding
    class SequencerRepository < AbstractRepository
      attr_reader :base_class

      def initialize(sequencer_config, base_class)
        @base_class = base_class
        @sequencer = { sequencer_config.name => generate_model_for_shard(sequencer_config.connection_name) }
      end

      def fetch(connection_name)
        @sequencer.fetch connection_name
      end

      private

      def generate_class_name(connection_name)
        "SequencerFor#{connection_name.to_s.tr('-', '_').classify}"
      end
    end
  end
end
