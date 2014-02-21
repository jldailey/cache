assert = require 'assert'
Cache = require './cache'

if require.main is module

	console.log "BASIC TEST:"
	cache = new Cache()
	cache.set 'key', 'value'
	assert.equal cache.get('key'), 'value'
	cache.remove 'key'
	assert.equal cache.get('key'), undefined

	console.log "EVICTION TEST:"
	cache = new Cache()
	cache.capacity = 10
	for i in [0...10]
		cache.set i, i
	assert.equal cache.length, 10
	cache.set 'a', 'a'
	assert.equal cache.length, 10
	assert.equal (cache.get 'a'), 'a'
	assert.equal (cache.get 9), 9
	assert.equal (cache.get 10), 10
	assert.equal (cache.get 0), undefined
	assert.equal (cache.get 1), undefined

	console.log "EFFICIENCY TEST:"
	cache = new Cache()
	cache.capacity = 11
	for i in [0...10]
		cache.set i, i # almost fill the cache
	for i in [0..100]
		cache.get i % 10 # increase efficiency for the base set
	assert.equal (cache.get 'a'), undefined
	cache.set 'a', 'a' # fill the cache with a last item
	assert.equal (cache.get 'a'), 'a'
	cache.set 'b', 'b' # overflow the cache, who gets evicted?
	# assert.equal (cache.get 'a'), undefined # a should be evicted
	

