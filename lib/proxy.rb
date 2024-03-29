require 'socket'
require 'json'
require 'Qt4'

class Proxy

	attr_accessor :login_completed, :get_field_completed, :step_completed, :opponent_step_completed

	def initialize server_address, server_port
		@socket = TCPSocket.open server_address, server_port
	end

	def close
		@socket.close
	end

	def login
		@socket.puts ({ 'type' => MESSAGE_LOGIN }.to_json)
	end

	def get_field
		@socket.puts ({ 'type' => MESSAGE_FIELD }.to_json)
	end

	def step row, col, value
		@socket.puts ({ 'type'  => MESSAGE_STEP,
			            'row'   => row,
			            'col'   => col,
			            'value' => value }.to_json)
	end

	def poll
		return unless socket_ready? @socket
		response = JSON.parse @socket.gets
		type = response['type']
		if type == MESSAGE_LOGIN
			@login_completed.call response unless @login_completed == nil
		elsif type == MESSAGE_FIELD
			@get_field_completed.call response unless @get_field_completed == nil
		elsif type == MESSAGE_STEP
			@step_completed.call response unless @step_completed == nil
		elsif type == MESSAGE_STEP_OPPONENT
			@opponent_step_completed.call response unless @opponent_step_completed == nil
		else
			print "wrong response type: #{type}"
		end
	end

	private

	def socket_ready? socket
		not IO.select([socket], nil, nil, 1) == nil
	end
end
