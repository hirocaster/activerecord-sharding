namespace :active_record_sharding do
  desc 'Show all defined clusters and their detail'
  task info: %i(environment) do
    ActiveRecordSharding::DatabaseTasks.info
  end

  desc 'Setup all databases in all clusters'
  task setup: %i(create_all load_schema_all) do
  end

  desc 'Create all databases in all clusters'
  task :create_all => :environment do
    ActiveRecordSharding::DatabaseTasks.invoke_task_for_all_clusters('create')
  end

  desc 'Drop all databases in all clusters'
  task :drop_all => :environment do
    ActiveRecordSharding::DatabaseTasks.invoke_task_for_all_clusters('drop')
  end

  desc 'Load schema to all databases in all clusters'
  task :load_schema_all => :environment do
    ActiveRecordSharding::DatabaseTasks.invoke_task_for_all_clusters('load_schema')
  end

  desc 'Create all databases in specific cluster'
  task :create, %i(cluster_name) => %i(environment) do |_, args|
    ActiveRecordSharding::DatabaseTasks.create_all_databases(args)
  end

  desc 'Drop all databases in specific cluster'
  task :drop, %i(cluster_name) => %i(environment) do |_, args|
    ActiveRecordSharding::DatabaseTasks.drop_all_databases(args)
  end

  desc 'Load schema to all databases in specific cluster'
  task :load_schema, %i(cluster_name) => %i(environment) do |_, args|
    ActiveRecordSharding::DatabaseTasks.load_schema_all_databases(args)
  end

  namespace :sequencer do
    desc 'Create database in specific sequencer'
    task :create, %i(sequencer_name) => %i(environment) do |_, args|
      ActiveRecordSharding::DatabaseTasks.create_sequencer_database(args)
    end

    desc 'Drop database in specific sequencer'
    task :drop, %i(sequencer_name) => %i(environment) do |_, args|
      ActiveRecordSharding::DatabaseTasks.drop_sequencer_database(args)
    end

    desc 'Create sequencer table in specific sequencer database'
    task :create_table, %i(sequencer_name) => %i(environment) do |_, args|
      ActiveRecordSharding::DatabaseTasks.create_table_sequencer_database(args)
    end

    desc 'Insert initial record in specific sequencer database'
    task :insert_initial_record, %i(sequencer_name) => %i(environment) do |_, args|
      ActiveRecordSharding::DatabaseTasks.insert_initial_record_sequencer_database(args)
    end
  end
end
