cache
=====

cache manager that supports: fixed-sizing, TTLs, and pubsub invalidation, and uses efficient eviction.

use like:

    Cache = require 'cache'
    
    cache = new Cache()
    
    cache.set('key', 'value', [ttl])
    
    cache.get('key')
    
    cache.remove('key')

All operations are synchronous (all data is local).

To get pubsub invalidation:

    cache.connect("amqp://guest:guest@localhost")

Messages should be published to "cache-activity".  They should look like:

    { "op": "remove", "key": "..." }
  
