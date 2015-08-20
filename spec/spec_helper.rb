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

    create_sequencer_table_sql = "CREATE TABLE user_id (id BIGINT unsigned NOT NULL DEFAULT 0)"
    ActiveRecordSharding::DatabaseTasks.execute('test_user_sequencer', create_sequencer_table_sql)
    insert_sequencer_table_sql = "INSERT INTO user_id VALUES (0)"
    ActiveRecordSharding::DatabaseTasks.execute('test_user_sequencer', insert_sequencer_table_sql)

    $stdout = back
  end

  config.after(:each) do
    User.all_shards.each &:delete_all
  end

  config.after(:suite) do
    ActiveRecordSharding::DatabaseTasks.drop_all_databases cluster_name: 'user'
    ActiveRecordSharding::DatabaseTasks.drop 'test_user_sequencer'
  end

  config.order = :random
  Kernel.srand config.seed
end
