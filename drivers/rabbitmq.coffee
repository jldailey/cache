amqp = require('amqp')
$ = require 'bling'

ready = $.Promise()

consumerTags = Object.create null

Cache.register_protocol "amqp", {
	connect: (url) ->
		connection = amqp.createConnection { url: url }
		connection.on 'ready', ->
			ready.finish connection
		connection.on 'error', (err) ->
			ready.fail err
	publish: (channel, message) ->
		ready.wait (err, connection) ->
			return if err
			connection.queue channel, (q) ->
				q.publish message
	subscribe: (channel, handler) ->
		ready.wait (err, connection) ->
			return if err
			connection.queue channel, (q) ->
				q.bind '#'
				q.subscribe((msg) -> handler null, msg)
					# take note of the consumer tag of the subscription
					.addCallback( (ok) -> consumerTags[channel] = ok.consumerTag )
	unsubscribe: (channel, handler) -> # handler gets (err, data)
		ready.wait (err, connection) ->
			return if err
			connection.queue channel, (q) ->
				return unless channel of consumerTags
				q.unsubscribe consumerTags[channel]
}

