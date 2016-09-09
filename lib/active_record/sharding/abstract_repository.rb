module ActiveRecord
  module Sharding
    class AbstractRepository
      private

        def generate_model_for_shard(connection_name)
          base_class_name = @base_class.name
          class_name      = generate_class_name connection_name

          return @base_class.const_get(class_name) if @base_class.const_defined?(class_name)

          @base_class.const_set(class_name, Class.new(base_class) do
            self.table_name = base_class.table_name

            module_eval <<-RUBY, __FILE__, __LINE__ + 1
              def self.name
                "#{base_class_name}::#{class_name}"
              end

              establish_connection(connection_name)
            RUBY
          end)
        end

        def generate_class_name(connection_name) # rubocop:disable Lint/UnusedMethodArgument
          raise NotImplementedError, "#{self.class.name}.#{__method__} is an abstract method."
        end
    end
  end
end
