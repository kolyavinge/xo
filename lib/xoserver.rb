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
					begin
						#print "server: accept client\n"
				  		try_process_request client
				  	rescue
				  		print @error
				  	end
				}
			}
		}
	end

	def stop
		@server.close if @server != nil
	end

	private

	def try_process_request client
		client_request = json_parse_or_default client.gets

	  	client_response = get_client_response client, client_request
	  	client.puts client_response.to_json
	  	#print "server: send message to client\n"

	  	opponent = get_opponent_for client
	  	opponent_response = get_opponent_response client_response
	  	opponent.puts opponent_response.to_json if opponent_response != nil
	  	#print "server: send message to opponent\n" if opponent_response != nil
	end

	def json_parse_or_default json
		begin
			return JSON.parse json
		rescue
			return { }
		end
	end

	def get_client_response client, request
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
				response['size'] = @game.field.size
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
			response['row'] = row
			response['col'] = col
			response['value'] = value
			response['success'] = success
			response['who_win'] = @game.who_win
		else
			response['error'] = 'illegal request'
		end
		
		return response
	end

	def get_opponent_response client_response
		if client_response['type'] == MESSAGE_STEP && client_response['success'] == true
			return { 'type'    => MESSAGE_STEP_OPPONENT,
				     'row'     => client_response['row'],
				     'col'     => client_response['col'],
				     'value'   => client_response['value'],
				     'who_win' => client_response['who_win'] }
		else
			return nil
		end
	end

	def get_opponent_for client
		@clients.find { |c| c != client }
	end
end
