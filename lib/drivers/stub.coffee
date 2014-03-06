$     = require 'bling'
Cache = require "../cache"

log = $.logger "[stub]"

ready = $.Promise()

# A stub driver implementation for use in tests
Cache.register_protocol "stub:", {
	connect: (url) ->
		ready.finish()
	publish: (c, m) ->
		$.publish c, m
	subscribe: (c, h) ->
		$.subscribe c, h
	unsubscribe: (c, h) ->
		$.unsubscribe c, h
	disconnect: ->
		ready.reset()
}

