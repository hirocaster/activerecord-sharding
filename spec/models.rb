base = { 'adapter' => 'sqlite3' }
ActiveRecord::Base.configurations = {
  'test_user_001' => base.merge('database' => 'user_001.sqlite3'),
  'test_user_002' => base.merge('database' => 'user_002.sqlite3'),
  'test_user_003' => base.merge('database' => 'user_003.sqlite3'),
  'test' => base.merge('database' => 'default.sqlite3')
}
ActiveRecord::Base.establish_connection(:test)

ActiveRecordSharding.configure do |config|
  config.define_cluster(:user) do |cluster|
    cluster.register_connection(:test_user_001)
    cluster.register_connection(:test_user_002)
    cluster.register_connection(:test_user_003)
  end
end

class User < ActiveRecord::Base
end
