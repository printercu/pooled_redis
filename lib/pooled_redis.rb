require 'pooled_redis/version'
require 'connection_pool'

ConnectionPool.class_eval do
  # Wraps pool and proxies every method to checked out connection.
  # Similar to Wrapper, but works on existing pool.
  class SimpleConnection < BasicObject
    def initialize(pool)
      @pool = pool
    end

    private

    def method_missing(name, *args, &block)
      @pool.with { |x| x.send name, *args, &block }
    end

    def respond_to_missing?(name, include_all = false)
      @pool.with { |x| x.respond_to?(name, include_all) }
    end
  end

  def simple_connection
    SimpleConnection.new(self)
  end
end

module PooledRedis
  # Override this method unless using Rails.
  def redis_config
    @redis_config = begin
      config = ActiveRecord::Base.connection_config[:redis].with_indifferent_access
      config[:driver] ||= :hiredis if defined?(Hiredis)
      config[:logger] = Rails.logger if Rails.env.development?
      config
    end
  end

  def redis_pool_config
    @redis_pool_config ||= {
      pool:     redis_config.delete(:pool)    || 5,
      timeout:  redis_config.delete(:timeout) || 5,
    }
  end

  def redis_pool
    @redis_pool ||= ConnectionPool.new(redis_pool_config) { Redis.new(redis_config) }
  end

  def redis
    @redis ||= redis_pool.simple_connection
  end
end

# Use Rails module methods to access redis client.
Rails.class_eval { extend PooledRedis } if defined?(Rails)
