require "active_support/concern"

module ActiveRecord
  module Sharding
    module Facade
      extend ActiveSupport::Concern

      include Model
      include Sequencer

      included do |base|
        base.before_put do |attributes|
          attributes[:id] ||= next_sequence_id
        end

        base.before_save on: :create do
          self.id ||= self.class.next_sequence_id
        end
      end
    end
  end
end
