cache
=====

cache manager that supports:

* fixed-sizing
* TTL expiration
* pubsub invalidation
* efficient eviction
* shared instances ("buckets")


use like:

    Cache = require 'cache'
    Cache.defineBucket("bucket_name", params...)
    # params are (in order)
    # capacity=Infinity
    # defaultTTL=Infinity
    # evictCount=EVICT_AUTO
    # evictPct=.25
    
    cache = Cache("bucket_name")
    
    cache.set('key', 'value', [ttl])
    
    cache.get('key')
    
    cache.remove('key')

All operations are synchronous (all data is local).

To get pubsub invalidation:

    cache.connect("amqp://guest:guest@localhost")

Messages should be published to "cache-activity".  They should look like:

    { "op": "remove", "key": "..." }
    { "op": "set", "key": "...", "value": "..." }
    { "op": "flush" }
  
