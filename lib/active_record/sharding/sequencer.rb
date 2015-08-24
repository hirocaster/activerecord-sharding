require 'active_support/concern'

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
          connection = sequencer_repository.fetch(sequencer_name).connection
          connection.execute "UPDATE `#{sequencer_config.table_name}` SET id = LAST_INSERT_ID(id)"
          res = connection.execute 'SELECT LAST_INSERT_ID()'
          new_id = res.first.first.to_i
          new_id
        end

        def next_sequence_id
          connection = sequencer_repository.fetch(sequencer_name).connection
          connection.execute "UPDATE `#{sequencer_config.table_name}` SET id = LAST_INSERT_ID(id +1)"
          res = connection.execute 'SELECT LAST_INSERT_ID()'
          new_id = res.first.first.to_i
          new_id
        end
      end
    end
  end
end
