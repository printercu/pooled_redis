# EasyRedis

Simple way to access redis connections without global variables.

Provides `Rails.redis_pool` & `Rails.redis` methods and configuration via `database.yml`.
You can add this methods to custom modules.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_redis'
```

## Usage

- Add `redis` section to your `database.yml` with options supported by `Redis.new`

```yml
development:
  redis:
    db: 2
production:
  redis:
    url: 'redis://mymaster'
    sentinels:
      - host: host
      - host: other
```

- You can also provide `pool` & `timeout` values for ConnectionPool.
- Use `Rails.redis_pool` & `Rails.redis` method.

EasyRedis uses ConnectionPool for pooling connections.
`.redis` returns proxy object that checkouts connection for every method call.
So you may want to avoid it for bulk operations.

### Without Rails or custom modules

- Extend or include `EasyRedis` module.
- Override `redis_config` method to return valid configuration.
- Use `redis_pool` & `redis` methods.

```ruby
class Storage
  extend EasyRedis

  class << self
    def redis_config
      read_your_yaml.symbolize_keys
    end
  end

  # ...

  def save
    self.class.redis.set id, to_json
  end
end

Storage.redis_pool.with { |r| r.get :some_key }
Storage.redis.get :some_key
```

# Licence

MIT
