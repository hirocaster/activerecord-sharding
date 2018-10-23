# frozen_string_literal: true
module ActiveRecord
  module Sharding
    class AbstractRepository
      private

        def generate_model_for_shard(connection_name)
          base_class_name = @base_class.name
          class_name = generate_class_name connection_name

          if ActiveRecord.version >= Gem::Version.new("5.0")
            generate_model_for_shard_ar5(connection_name, base_class_name, class_name)
          else
            generate_model_for_shard_ar4(connection_name, base_class_name, class_name)
          end
        end

        def generate_model_for_shard_ar4(connection_name, base_class_name, class_name)
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

        def generate_model_for_shard_ar5(connection_name, base_class_name, class_name)
          a_class = Class.new(base_class) do
            module_eval <<-RUBY, __FILE__, __LINE__ + 1
                    def self.name
                      "#{class_name}"
                    end
                  RUBY
          end
          a_class.class_eval { abstract_class = true }
          a_class.class_eval do
            if ActiveRecord::Base.connection_handler.connection_pool_list.map { |c| c.spec.name }.include?(name)
              self.connection_specification_name = name
            else
              establish_connection(connection_name)
            end
          end

          model = Class.new(a_class) do
            self.table_name = base_class.table_name
            module_eval <<-RUBY, __FILE__, __LINE__ + 1
                    def self.name
                      "#{base_class_name}::#{class_name}"
                    end
                  RUBY
          end
          model
        end

        def generate_class_name(connection_name) # rubocop:disable Lint/UnusedMethodArgument
          raise NotImplementedError, "#{self.class.name}.#{__method__} is an abstract method."
        end
    end
  end
end
