module EstablishConnectionForShard
  def establish_connection_for_shard(config = nil)
    if ActiveRecord::Base.connection_handler.connection_pool_list.map { |c| c.spec.name }.include?(name)
      self.connection_specification_name = name
    else
      establish_connection(config)
    end
  end
end
ActiveRecord::ConnectionHandling.send(:prepend, EstablishConnectionForShard)

module ActiveRecord
  module Sharding
    class AbstractRepository
      private

        def generate_model_for_shard(connection_name)
          base_class_name = @base_class.name
          class_name = generate_class_name connection_name

          a_class = Class.new(base_class) do
            module_eval <<-RUBY, __FILE__, __LINE__ + 1
                    def self.name
                      "#{class_name}"
                    end
                  RUBY
          end
          a_class.class_eval { abstract_class = true }
          a_class.class_eval { establish_connection_for_shard(connection_name) }

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
