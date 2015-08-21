require 'simplecov'
SimpleCov.start do
  add_filter 'vendor'
  add_filter 'spec'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_record_sharding'
require 'pry'
require 'pry-byebug'
require 'awesome_print'

require_relative 'models'

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Tasks::DatabaseTasks.db_dir = File.expand_path '..', __FILE__
    ActiveRecord::Tasks::DatabaseTasks.root   = File.expand_path '../..', __FILE__
    ActiveRecord::Tasks::DatabaseTasks.env    = 'test'

    back, $stdout = $stdout, StringIO.new
    args = { cluster_name: 'user' }
    ActiveRecordSharding::DatabaseTasks.drop_all_databases args
    ActiveRecordSharding::DatabaseTasks.create_all_databases args
    ActiveRecordSharding::DatabaseTasks.load_schema_all_databases args

    sequencer_args = { sequencer_name: 'user' }
    ActiveRecordSharding::DatabaseTasks.drop_sequencer_database sequencer_args
    ActiveRecordSharding::DatabaseTasks.create_sequencer_database sequencer_args
    ActiveRecordSharding::DatabaseTasks.create_table_sequencer_database sequencer_args
    ActiveRecordSharding::DatabaseTasks.insert_initial_record_sequencer_database sequencer_args

    $stdout = back

    ActiveRecord::Base.establish_connection(:test)
  end

  config.after(:each) do
    User.all_shards.each(&:delete_all)
  end

  config.after(:suite) do
    ActiveRecordSharding::DatabaseTasks.drop_all_databases cluster_name: 'user'

    sequencer_args = { sequencer_name: 'user' }
    ActiveRecordSharding::DatabaseTasks.drop_sequencer_database sequencer_args
  end

  config.order = :random
  Kernel.srand config.seed
end
