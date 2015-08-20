base = { 'adapter' => 'mysql2', 'encoding' => 'utf8', 'pool' => 5, 'username' => 'root', 'password' => '', 'host' => 'localhost' }
ActiveRecord::Base.configurations = {
  'test_user_001' => base.merge('database' => 'user_001'),
  'test_user_002' => base.merge('database' => 'user_002'),
  'test_user_003' => base.merge('database' => 'user_003'),
  'test_user_sequencer' => base.merge('database' => 'user_sequencer'),
  'test' => base.merge('database' => 'default')
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
    sequencer.register_table_name('user_id')
  end
end

class User < ActiveRecord::Base
  def items
    return [] unless id
    Item.shard_for(id).where(user_id: id).all
  end

  include ActiveRecordSharding::Model
  use_sharding :user
  define_sharding_key :id

  include ActiveRecordSharding::Sequencer
  use_sequencer :user

  before_put do |attributes|
    attributes[:id] = next_sequence_id unless attributes[:id]
  end
end

class Item < ActiveRecord::Base
  def user
    return unless user_id
    User.shard_for(user_id).find_by user_id
  end

  include ActiveRecordSharding::Model
  use_sharding :user
  define_sharding_key :user_id
end
