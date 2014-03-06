assert = require 'assert'
Cache = require './cache'
$ = require 'bling'

exports.testSetGetRemove = (test) ->
	cache = new Cache()
	test.equal cache.length, 0
	cache.set 'key', 'value'
	test.equal cache.length, 1
	test.equal cache.get('key'), 'value'
	cache.remove 'key'
	test.equal cache.get('key'), undefined
	test.done()

exports.testEviction = (test) ->
	cache = new Cache()
	cache.capacity = 10
	cache.evictPct = .3
	for i in [0...10] # fill the cache
		cache.set i, i
	test.equal cache.length, 10
	cache.set 'key', 'value'
	test.equal cache.length, Math.floor(cache.capacity * (1 - cache.evictPct)) + 1
	test.equal cache.get('key'), 'value'
	test.done()

exports.testEfficiency = (test) ->
	cache = new Cache()
	cache.capacity = 10
	cache.evictPct = .2
	for i in [0...8] # almost fill the cache
		cache.set i, i
	cache.set 'a', 'a'
	cache.set 'b', 'b'
	# the cache is now full
	# so bump up the efficiency of our test keys
	for i in [0...10]
		cache.get 'a'
		cache.get 'b'
	# add a new key to trigger eviction
	cache.set 'c', 'c'
	# ensure our preferred keys were not evicted
	test.equal cache.get('a'), 'a'
	test.equal cache.get('b'), 'b'
	test.equal cache.get('c'), 'c'
	test.done()

exports.testPubSubInvalidateWithStub = (test) ->
	log = $.logger "[stub-test]"
	cache = new Cache()
	cache.set 'a', 'a'
	cache.set 'b', 'b'
	cache.set 'c', 'c'
	cache.connect("stub://").then ->
		$.publish 'cache-activity', JSON.stringify { op: "remove", key: "b" }
		$.delay 100, ->
			test.deepEqual cache.get('a','b','c'), ['a',undefined,'c']
			log "calling cache.disconnect"
			cache.disconnect()
			test.done()

exports.testPubSubInvalidateWithRabbitMq = (test) ->
	log = $.logger "[rabbit-test]"
	cache = new Cache()
	cache.set 'a', 'a'
	cache.set 'b', 'b'
	cache.set 'c', 'c'
	amqp_url = "amqp://localhost:5672"
	cache.connect(amqp_url).then ->
		context = require('rabbit.js').createContext(amqp_url)
		pub = context.socket('PUB')
		pub.connect 'cache-activity', ->
			pub.write JSON.stringify({ op: "remove", key: "b" }), 'utf8'
			$.delay 100, ->
				test.deepEqual cache.get('a','b','c'), ['a',undefined,'c']
				log "calling cache.disconnect"
				cache.disconnect(amqp_url)
				pub.close()
				test.done()

