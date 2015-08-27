module ActiveRecord
  module Sharding
    module DatabaseTasks
      extend self

      def info
        puts "All clusters registered to activerecord-sharding"
        puts
        clusters.each do |cluster|
          puts "= Cluster: #{cluster.name} ="
          cluster.connections.each do |name|
            puts "- #{name}"
          end
          puts
        end
        puts_sequencers
      end

      def puts_sequencers
        return unless sequencers

        puts "All sequencers registered to activerecord-sharding"
        puts
        sequencers.each do |sequencer|
          puts "= Sequencer: #{sequencer.name} ="
          puts "- Connection:#{sequencer.connection_name} Table:#{sequencer.table_name}"
          puts
        end
      end

      def ar5?
        ActiveRecord::VERSION::MAJOR == 5
      end

      def ar4?
        ActiveRecord::VERSION::MAJOR == 4
      end

      def ar42?
        ar4? && ActiveRecord::VERSION::MINOR == 2
      end

      def ar41?
        ar4? && ActiveRecord::VERSION::MINOR == 1
      end

      def ar417_above?
        ar41? && ActiveRecord::VERSION::TINY > 7
      end

      def clusters
        ActiveRecord::Sharding.config.cluster_configs.values
      end

      def cluster_names
        ActiveRecord::Sharding.config.cluster_configs.keys
      end

      def sequencer_names
        ActiveRecord::Sharding.config.sequencer_configs.keys
      end

      def fetch_cluster_config(cluster_name)
        ActiveRecord::Sharding.config.fetch_cluster_config cluster_name
      end

      def sequencers
        ActiveRecord::Sharding.config.sequencer_configs.values
      end

      def fetch_sequencer_config(sequencer_name)
        ActiveRecord::Sharding.config.fetch_sequencer_config sequencer_name
      end

      def to_rake_task(task_name)
        Rake::Task[task_name]
      end

      module TasksForMultipleClusters
        def invoke_task_for_all_clusters(task_name)
          cluster_names.each do |cluster_name|
            invoke_task task_name, cluster_name
          end
        end

        def invoke_task(name, cluster_name)
          task_name = "active_record:sharding:#{name}"
          to_rake_task(task_name).invoke cluster_name.to_s
          to_rake_task(task_name).reenable
        end

        def invoke_task_for_all_sequencers(task_name)
          sequencer_names.each do |sequencer_name|
            invoke_task_for_sequencer task_name, sequencer_name
          end
        end

        def invoke_task_for_sequencer(name, sequencer_name)
          task_name = "active_record:sharding:sequencer:#{name}"
          to_rake_task(task_name).invoke sequencer_name.to_s
          to_rake_task(task_name).reenable
        end
      end
      extend TasksForMultipleClusters

      module TaskOrganizerForSingleClusterTask
        def create_all_databases(args)
          exec_task_for_all_databases "create", args
        end

        def drop_all_databases(args)
          exec_task_for_all_databases "drop", args
        end

        def load_schema_all_databases(args)
          exec_task_for_all_databases "load_schema", args
        end

        private

        def exec_task_for_all_databases(task_name, args)
          cluster_name = cluster_name_or_error task_name, args
          cluster = cluster_or_error cluster_name
          cluster.connections.each do |connection_name|
            __send__ task_name, connection_name.to_s
          end
        end

        def cluster_name_or_error(name, args)
          unless cluster_name = args[:cluster_name]
            $stderr.puts <<-MSG
Missing cluster_name. Find cluster_name via `rake active_record:sharding:info` then call `rake "active_record:sharding:#{name}[$cluster_name]"`.
          MSG
            exit
          end
          cluster_name
        end

        def cluster_or_error(cluster_name)
          fetch_cluster_config cluster_name.to_sym
        rescue KeyError
          $stderr.puts %(cluster name "#{cluster_name}" not found.)
          exit
        end
      end
      extend TaskOrganizerForSingleClusterTask

      module TasksForSingleConnection
        def create(connection_name)
          configuration = ActiveRecord::Base.configurations[connection_name]
          ActiveRecord::Tasks::DatabaseTasks.create(configuration)
          ActiveRecord::Base.establish_connection(configuration)
        end

        def drop(connection_name)
          configuration = ActiveRecord::Base.configurations[connection_name]
          ActiveRecord::Tasks::DatabaseTasks.drop configuration
        end

        def execute(connection_name, sql)
          configuration = ActiveRecord::Base.configurations[connection_name]
          ActiveRecord::Base.establish_connection(configuration).connection.execute sql
        end

        def load_schema(connection_name)
          configuration = ActiveRecord::Base.configurations[connection_name]

          case
          when ar5?
            ActiveRecord::Tasks::DatabaseTasks.load_schema configuration, :ruby
          when ar42? || ar417_above?
            ActiveRecord::Tasks::DatabaseTasks.load_schema_for configuration, :ruby
          when ar41?
            ActiveRecord::Base.establish_connection configuration
            ActiveRecord::Tasks::DatabaseTasks.load_schema :ruby
          else
            fail "This version of ActiveRecord is not supported: v#{ActiveRecord::VERSION::STRING}"
          end
        end
      end
      extend TasksForSingleConnection

      module TasksForSingleSequencerTask
        def create_sequencer_database(args)
          exec_task_for_sequencer_database "create", args
        end

        def drop_sequencer_database(args)
          exec_task_for_sequencer_database "drop", args
        end

        def create_table_sequencer_database(args)
          sequencer = sequencer_or_error "create_table", args
          create_table_sql = "CREATE TABLE #{sequencer.table_name} (id BIGINT unsigned NOT NULL DEFAULT 0) ENGINE=MyISAM"
          execute sequencer.connection_name.to_s, create_table_sql
        end

        def insert_initial_record_sequencer_database(args)
          sequencer = sequencer_or_error "insert_initial_record", args
          insert_initial_record_sql = "INSERT INTO #{sequencer.table_name} VALUES (0)"
          execute sequencer.connection_name.to_s, insert_initial_record_sql
        end

        private

        def exec_task_for_sequencer_database(task_name, args)
          sequencer = sequencer_or_error task_name, args
          __send__ task_name, sequencer.connection_name.to_s
        end

        def sequencer_or_error(task_name, args)
          sequencer_name = sequencer_name_or_error task_name, args
          fetch_sequencer_config sequencer_name.to_sym
        rescue KeyError
          $stderr.puts %(sequencer name "#{sequencer_name}" not found.)
          exit
        end

        def sequencer_name_or_error(task_name, args)
          unless sequencer_name = args[:sequencer_name]
            # rubocop:disable Metrics/LineLength
            $stderr.puts <<-MSG
Missing sequencer_name. Find sequencer_name via `rake active_record:sharding:info` then call `rake "active_record:sharding:sequencer#{task_name}[$sequencer_name]"`.
          MSG
            exit
            # rubocop:enable Metrics/LineLength
          end
          sequencer_name
        end
      end
      extend TasksForSingleSequencerTask
    end # module DatabaseTasks
  end
end
