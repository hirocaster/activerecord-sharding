module ActiveRecord
  module Sharding
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load File.expand_path('../../../tasks/activerecord-sharding.rake', __FILE__)
      end
    end
  end
end
