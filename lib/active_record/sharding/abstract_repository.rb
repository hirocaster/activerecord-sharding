module ActiveRecord
  module Sharding
    class AbstractRepository
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

        def generate_class_name(connection_name) # rubocop:disable Lint/UnusedMethodArgument
          fail NotImplementedError, "#{self.class.name}.#{__method__} is an abstract method."
        end
    end
  end
end
