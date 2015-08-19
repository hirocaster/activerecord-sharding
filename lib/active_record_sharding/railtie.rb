module ActiveRecordSharding
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load File.expand_path('../../tasks/active_record_sharding.rake', __FILE__)
    end
  end
end
