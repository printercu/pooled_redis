# PooledRedis

Simple way to access redis connections without global variables.

Provides `Rails.redis_pool` & `Rails.redis` methods and configuration via `database.yml`.
You can add this methods to custom modules.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pooled_redis'
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
- Use `debug: true` to set redis logger to `Rails.logger`.
- Use `Rails.redis_pool` & `Rails.redis` method.

PooledRedis uses ConnectionPool for pooling connections.
`.redis` returns proxy object that checkouts connection for every method call.
So you may want to avoid it for bulk operations.

### Rails.cache configuration & Redis::Store support
PooledRedis provides configuration of `Rails.cache` via `database.yml`.
To enable this add following to your `config/application.rb` (inside `Application` class):

```ruby
PooledRedis.setup_rails_cache(self)
```

And cache sections to `database.yml`:

```yml
development:
  cache:
    adapter: redis_store
    db: 3
    expires_in: 3600

production:
  cache:
    adapter: redis_store
    url: 'redis://mycachemaster'
    sentinels:
      - host: host
      - host: other

# You can also use other adapters:
test:
  cache:
    adapter: null_store
```

You need to add `gem 'redis-activesupport'` to your Gemfile.
It supports only new version of `Redis::Store` with support of ConnectionPool
(currently it's only available in master:
`gem 'redis-activesupport', '~> 4.0.0', github: 'redis-store/redis-activesupport', ref: 'd09ae04'`).

### Custom modules or without rails

- Extend or include `PooledRedis` module.
- Override `redis_config` method to return valid configuration.
- Use `redis_pool` & `redis` methods.

```ruby
class Storage
  extend PooledRedis

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
