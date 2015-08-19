base = { 'adapter' => 'sqlite3' }
ActiveRecord::Base.configurations = {
  'test_user_001' => base.merge('database' => 'user_001.sqlite3'),
  'test_user_002' => base.merge('database' => 'user_002.sqlite3'),
  'test_user_003' => base.merge('database' => 'user_003.sqlite3'),
  'test_user_sequencer' => base.merge('database' => 'user_sequencer.sqlite3'),
  'test' => base.merge('database' => 'default.sqlite3')
}
ActiveRecord::Base.establish_connection(:test)

ActiveRecordSharding.configure do |config|
  config.define_cluster(:user) do |cluster|
    cluster.register_connection(:test_user_001)
    cluster.register_connection(:test_user_002)
    cluster.register_connection(:test_user_003)
  end

  config.define_sequencer(:user) do |sequencer|
    sequencer.register_connection(:test_user_sequencer)
    sequencer.register_table_name("user_id")
  end
end

class User < ActiveRecord::Base
  include ActiveRecordSharding::Model
  use_sharding :user
  define_sharding_key :id

  include ActiveRecordSharding::IdSequencer
  use_sequencer :user

  before_put do |attributes|
    attributes[:id] = next_sequence_id unless attributes[:id]
  end
end
