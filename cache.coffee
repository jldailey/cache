$ = require 'bling'
Url = require 'url'
assert = require 'assert'
log = $.logger "[cache]"

# Implement an efficient cache that supports:
# - fixed-sizing
# - TTL per key
# - pubsub invalidation

EVICT_AUTO = -1

module.exports = class Cache

	protocols = Object.create null
	Cache.register_protocol = (proto, impl) ->
		protocols[proto] = impl

	constructor: (
		@capacity=Infinity,
		@defaultTTL=Infinity,
		@evictCount=EVICT_AUTO,
		@evictPct=.25, # only applies if EVICT_AUTO
	) ->

		# cache items are stored under their cache key
		# the stored items are like { r: <# of get> w: <# of set>, k: key, v: item }
		index = Object.create null

		# for tracking each key in order of efficiency
		# (so we can quickly evict the least efficient)
		order = []

		# define efficiency of a cache item
		# (reversed so low efficiency items are at the end)
		eff = (key) ->
			return Infinity unless key of index
			item = index[key]
			return -item.r / item.w

		autoEvict = => # make room in the cache if needed
			if order.length >= @capacity
				evictCount = switch @evictCount
					when EVICT_AUTO then @capacity * @evictPct
					else @evictCount
				for key in order.splice order.length - evictCount, evictCount
					delete index[key]
			null

		reIndex = (i, j) ->
			for x in [i..j]
				continue unless x of order
				continue unless order[x] of index
				index[order[x]].i = x

		reOrder = (item) -> # shift item into sorted order
			return unless item
			i = item.i
			# find it's proper position
			j = $.sortedIndex order, item.k, eff
			if j isnt i
				order.splice i, 1 # remove from current position
				order.splice j, 0, item.k # insert into new position
				reIndex i, j
			return item

		$.defineProperty @, 'length',
			get: -> order.length

		@remove = (key) ->
			return unless key of index
			order.splice index[key].i, 1
			reIndex index[key].i, order.length - 1
			delete index[key]

		@get = (keys...) ->
			ret = $(keys).map (key) -> return switch true
				when key of index
					item = index[key]
					item.r += 1
					reOrder item
					item.v
				else undefined

			switch ret.length
				when 1 then ret[0]
				else ret

		@set = (key, value, ttl=@defaultTTL) =>
			autoEvict()
			if key of index
				item = index[key]
				item.w += 1
			else # create a new cache item
				index[key] = item = {
					r: 0.0, # number of gets
					w: 1.0, # number of sets (counting this one)
					i: order.length, # efficiency rank
					k: key,
					v: value
				}
				order.push item.k
			if ttl < Infinity
				setTimeout (=> @remove key), ttl
			# cache-hits and misses can change efficiency
			# so we always re-order
			reOrder item
			return item.v
	

		connections = []
		@connect = (url) =>
			p = $.Promise()
			parsed = Url.parse url
			unless parsed.protocol of protocols
				p.fail "unknown protocol", parsed.protocol
			impl = protocols[parsed.protocol]
			impl.connect(url).then (connection) =>
				connections[url] = impl
				log "connected, subscribing to cache-activity"
				impl.subscribe "cache-activity", (message) =>
					log "I see cache-activity:", message
					try
						obj = JSON.parse String(message)
						log "parsed:", JSON.stringify(obj)
						assert 'op' of obj, "Message must contain an 'op'."
						assert 'key' of obj, "Message must contain a 'key'."
					catch err
						return p.fail err
					switch obj.op
						when 'remove' then @remove obj.key
						when 'set' then @set obj.key, obj.value
						else log "unknown op:", obj.op
					null
				p.finish()
			p

		@disconnect = (url) =>
			connections[url]?.disconnect()


require "./drivers"
