# ActiveRecordSharding

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/active_record_sharding`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_sharding'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_sharding

## Usage

Add database connections to your application's config/database.yml:

```yaml
default: &default
  adapter: mysql2
  encoding: utf8
  pool: 5
  username: root
  password:
  host: localhost

user_sequencer:
  <<: *default
  database: user_001
  host: localhost

user_001:
  <<: *default
  database: user_001
  host: localhost

user_002:
  <<: *default
  database: user_002
  host: localhost

user_003:
<<: *default
  database: user_003
  host: localhost
```

Add this example  your application's config/initializers/active_record_sharding.rb:

```ruby
ActiveRecordSharding.configure do |config|
  config.define_sequencer(:user) do |sequencer|
    sequencer.register_connection(:user_sequencer)
    sequencer.register_table_name('user_id')
  end

  config.define_cluster(:user) do |cluster|
    cluster.register_connection(:user_001)
    cluster.register_connection(:user_002)
    cluster.register_connection(:user_003)
  end
end
```

- define user cluster config
- define user sequencer config

### Model

app/model/user.rb

```ruby
class User < ActiveRecord::Base
  include ActiveRecordSharding::Model
  use_sharding :user
  define_sharding_key :id

  include ActiveRecordSharding::Sequencer
  use_sequencer :user

  before_put do |attributes|
    attributes[:id] = next_sequence_id unless attributes[:id]
  end
end
```


### Create sequencer dtabase

```ruby
$ rake active_record_sharding:sequencer:create[user]
$ rake active_record_sharding:sequencer:create_table[user]
$ rake active_record_sharding:sequencer:insert_initial_record[user]
```

### Create cluster dtabases

```ruby
$ rake active_record_sharding:create_all
```

and, migrations all cluster databases.

### in applications

#### Create

using `#put!` method.

```ruby
user = User.put! name: 'foobar'
```

returns User new object.

#### Select Query

```ruby
sharding_key = user.id
User.shard_for(sharding_key).where(name: 'foorbar')
```

`sharding_key` is your define_syarding_key.(example is User Object id)

`#sahrd_for` is returns User class.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/active_record_sharding.
