$      = require 'bling'
Rabbit = require 'rabbit.js'
Cache  = require '../cache'

logger = require('logger') "rabbitmq"

ready = $.Promise()

sockets = Object.create null

Cache.register_protocol "amqp:", {

	connect: (url) ->
		context = Rabbit.createContext(url)
		context.on 'ready', ->
			ready.finish context
		context.on 'error', (err) ->
			ready.fail err
		ready

	publish: (channel, message) ->
		p = $.Promise()
		ready.then (context) -> # for now we ignore the channel
			pub = context.socket('PUB')
			pub.connect channel, ->
				pub.end JSON.stringify(message), 'utf8'
				p.finish()
		p

	subscribe: (channel, handler) ->
		p = $.Promise()
		ready.then (context) ->
			sub = context.socket('SUB')
			sub.connect channel, ->
				sub.on 'data', handler
				sub.on 'error', (err) ->
					console.error "Error in sub to ", channel, err
				if channel of sockets
					sockets[channel].close()
				sockets[channel] = sub
				p.finish()
		p

	unsubscribe: (channel, handler) -> # handler gets (err, data)
		if channel of sockets
			sockets[channel].close()
		$.Promise().finish()
	
	disconnect: ->
		ready.then (context) ->
			context.close()
			for channel, sub of sockets
				sub.close()
}

