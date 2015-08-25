require "simplecov"
require "coveralls"
Coveralls.wear!
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter "/spec"
  add_filter "/vendor"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "activerecord-sharding"
require "pry"
require "pry-byebug"
require "awesome_print"

require_relative "models"

log_directry = File.expand_path("../../log/", __FILE__)
Dir.mkdir log_directry unless Dir.exist? log_directry
ActiveRecord::Base.logger = Logger.new("#{log_directry}/test.log")

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Tasks::DatabaseTasks.db_dir = File.expand_path "..", __FILE__
    ActiveRecord::Tasks::DatabaseTasks.root   = File.expand_path "../..", __FILE__
    ActiveRecord::Tasks::DatabaseTasks.env    = "test"

    back, $stdout = $stdout, StringIO.new
    args = { cluster_name: "user" }
    ActiveRecord::Sharding::DatabaseTasks.drop_all_databases args
    ActiveRecord::Sharding::DatabaseTasks.create_all_databases args
    ActiveRecord::Sharding::DatabaseTasks.load_schema_all_databases args

    sequencer_args = { sequencer_name: "user" }
    ActiveRecord::Sharding::DatabaseTasks.drop_sequencer_database sequencer_args
    ActiveRecord::Sharding::DatabaseTasks.create_sequencer_database sequencer_args
    ActiveRecord::Sharding::DatabaseTasks.create_table_sequencer_database sequencer_args
    ActiveRecord::Sharding::DatabaseTasks.insert_initial_record_sequencer_database sequencer_args

    $stdout = back

    ActiveRecord::Base.establish_connection(:test)
  end

  config.after(:each) do
    User.all_shards.each(&:delete_all)
  end

  config.after(:suite) do
    ActiveRecord::Sharding::DatabaseTasks.drop_all_databases cluster_name: "user"

    sequencer_args = { sequencer_name: "user" }
    ActiveRecord::Sharding::DatabaseTasks.drop_sequencer_database sequencer_args
  end

  config.order = :random
  Kernel.srand config.seed
end
