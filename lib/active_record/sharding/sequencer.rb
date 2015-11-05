require "active_support/concern"

module ActiveRecord
  module Sharding
    module Sequencer
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
          execute_current_id_sql "id"
        end

        def next_sequence_id
          current_sequence_id + 1
        end

        def count_up_sequence_id
          execute_count_up_sql "id +1"
        end

        def execute_count_up_sql(last_insert_id_args)
          connection = sequencer_repository.fetch(sequencer_name).connection
          connection.execute "UPDATE `#{sequencer_config.table_name}` SET id = LAST_INSERT_ID(#{last_insert_id_args})"
          res = connection.execute "SELECT LAST_INSERT_ID()"
          new_id = res.first.first.to_i
          new_id
        end

        def execute_current_id_sql(last_insert_id_args)
          connection = sequencer_repository.fetch(sequencer_name).connection
          res = connection.execute "SELECT LAST_INSERT_ID()"
          current_id = res.first.first.to_i
          current_id
        end
      end
    end
  end
end
