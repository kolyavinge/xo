require 'game'
require 'socket'
require 'json'

XOSERVER_DEFAULT_PORT = 4554

class XOServer

	def initialize port=XOSERVER_DEFAULT_PORT
		@port = port
		@game = Game.new
		@xo = X
		@clients = []
	end

	def run
		@server = TCPServer.open @port
		loop {
			Thread.start(@server.accept) { |client|
				loop {
				  	request = JSON.parse client.gets
				  	response = proccess client, request
				  	client.puts response.to_json
				}
			}
		}
	end

	def stop
		@server.close if @server != nil
	end

	private

	def proccess client, request
		message_type = request['type']
		
		response = { 'type' => message_type }

		if message_type == MESSAGE_LOGIN
			if @clients.include? client
				response['error'] = 'you are already logged'
				return response
			end

			if @xo == nil
				response['error'] = 'server is full'
			else
				response['xo'] = @xo
				@xo = if @xo == X then O else nil end
				@clients << client
			end

			return response
		end

		if not @clients.include? client
			response['error'] = 'you are not logged'
			return response
		end
		
		if message_type == MESSAGE_FIELD
			response['cells'] = @game.field.to_a
		elsif message_type == MESSAGE_STEP
			row, col, value = request['row'], request['col'], request['value']
		success = @game.step row, col, value
		response['success'] = success
		response['who_win'] = @game.who_win
		else
			response['error'] = 'illegal request'
		end
		
		return response
	end
end
