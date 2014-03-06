$ = require 'bling'
Cache = require "../cache"
Q = require 'q'
hub = $
log = $.logger "[stub]"

ready = $.Promise()

# A stub driver implementation for use in tests
Cache.register_protocol "stub:", {
	connect: (url) ->
		ready.finish()
	publish: (c, m) ->
		hub.publish c, m
	subscribe: (c, h) ->
		hub.subscribe c, h
	unsubscribe: (c, h) ->
		hub.unsubscribe c, h
	disconnect: ->
		ready.reset()
}

