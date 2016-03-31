require "active_support/concern"

module ActiveRecord
  module Sharding
    module Sequencer

      class Error < ActiveRecord::Sharding::Error
      end

      class NegativeNumberOffsetError < Error
      end

      extend ActiveSupport::Concern

      included do
        class_attribute :sequencer_repository, instance_writer: false
        class_attribute :sequencer_name, instance_writer: false
        class_attribute :sequencer_config, instance_writer: false
      end

      module ClassMethods
        def use_sequencer(name)
          self.sequencer_name = name
          self.sequencer_config = ActiveRecord::Sharding.config.fetch_sequencer_config name
          self.sequencer_repository = ActiveRecord::Sharding::SequencerRepository.new sequencer_config, self
          self.abstract_class = true
        end

        def current_sequence_id
          execute_sql "id"
        end

        def next_sequence_id(offset = 1)
          raise NegativeNumberOffsetError if offset < 1
          sequence_id = execute_sql "id +#{offset}"
          raise ActiveRecord::Sharding::InvalidSequenceId if sequence_id.zero?
          sequence_id
        end

        def execute_sql(last_insert_id_args)
          sequencer_klass = sequencer_repository.fetch(sequencer_name)
          connection = sequencer_klass.connection
          connection.execute "UPDATE `#{sequencer_config.table_name}` SET id = LAST_INSERT_ID(#{last_insert_id_args})", sequencer_klass.name
          res = connection.execute "SELECT LAST_INSERT_ID()", sequencer_klass.name
          new_id = res.first.first.to_i
          new_id
        end
      end
    end
  end
end
