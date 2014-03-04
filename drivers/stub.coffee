$ = require 'bling'
hub = new $.Hub()


# A stub driver implementation for use in tests
Cache.register_protocol "stub", {
	connect: (url) ->
	publish: (c, m) -> hub.publish c, m
	subscribe: (c, h) -> hub.subscribe c, h
	unsubscribe: (c, h) -> hub.unsubscribe c, h
}

