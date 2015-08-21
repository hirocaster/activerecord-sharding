#!/usr/bin/env ruby

require 'bundler/setup'
require 'active_record_sharding'

require_relative '../spec/models'

require 'benchmark'
require 'pry'

GENERATE_ID_COUNT = 100_000

def before_benchmark
  setup_database_env

  back, $stdout = $stdout, StringIO.new
  setup_shard_cluster_databases
  setup_sequence_database
  $stdout = back

  ActiveRecord::Base.establish_connection(:test)

  unless User.current_sequence_id == 0
    puts 'Fail: Start sequence id is not zero.'
    exit
  end
end

def setup_database_env
  ActiveRecord::Tasks::DatabaseTasks.db_dir = File.expand_path '../../spec', __FILE__
  ActiveRecord::Tasks::DatabaseTasks.root   = File.expand_path '../..', __FILE__
  ActiveRecord::Tasks::DatabaseTasks.env    = 'test'
end

def setup_shard_cluster_databases
  args = { cluster_name: 'user' }
  ActiveRecordSharding::DatabaseTasks.drop_all_databases args
  ActiveRecordSharding::DatabaseTasks.create_all_databases args
  ActiveRecordSharding::DatabaseTasks.load_schema_all_databases args
end

def setup_sequence_database
  sequencer_args = { sequencer_name: 'user' }
  ActiveRecordSharding::DatabaseTasks.drop_sequencer_database sequencer_args
  ActiveRecordSharding::DatabaseTasks.create_sequencer_database sequencer_args
  ActiveRecordSharding::DatabaseTasks.create_table_sequencer_database sequencer_args
  ActiveRecordSharding::DatabaseTasks.insert_initial_record_sequencer_database sequencer_args
end

def after_benchmark
  if User.current_sequence_id != GENERATE_ID_COUNT
    puts "Fail: End sequence id is not #{GENERATE_ID_COUNT}."
  end

  ActiveRecordSharding::DatabaseTasks.drop_all_databases cluster_name: 'user'

  sequencer_args = { sequencer_name: 'user' }
  ActiveRecordSharding::DatabaseTasks.drop_sequencer_database sequencer_args
end

before_benchmark

puts "===== Benchmark sequence id (#{GENERATE_ID_COUNT}) ====="
puts Benchmark::CAPTION
puts Benchmark.measure {
       100_000.times do
         User.next_sequence_id
       end
     }

after_benchmark
