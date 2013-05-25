#!/usr/bin/ruby

$LOAD_PATH.unshift('../lib')
$LOAD_PATH.unshift('.')

require 'unittest'
require 'contracts'
require 'json'
require 'xoserver'

class XOServerTest < Test::Unit::TestCase
	def setup
		@host = 'localhost'
	end

	def teardown
		@server.stop if @server != nil
		@socket.close if @socket != nil

	end

	def run_server_in_background
		Thread.start {
			@server = XOServer.new(@port)
			@server.run
		}
		sleep 0.01
	end

	# integration tests

	def test_login
		print "\ntest_login "
        @port = 99993
		run_server_in_background
		
		@socket = TCPSocket.open @host, @port
		request = { 'type' => MESSAGE_LOGIN }.to_json
		@socket.puts request
		response = JSON.parse @socket.gets
		assert_equal({ 'type' => MESSAGE_LOGIN, 'xo' => X }, response)

		@socket = TCPSocket.open @host, @port
		request = { 'type' => MESSAGE_LOGIN }.to_json
		@socket.puts request
		response = JSON.parse @socket.gets
		assert_equal({ 'type' => MESSAGE_LOGIN, 'xo' => O }, response)

		@socket = TCPSocket.open @host, @port
		request = { 'type' => MESSAGE_LOGIN }.to_json
		@socket.puts request
		response = JSON.parse @socket.gets
		assert_equal({ 'type' => MESSAGE_LOGIN, 'error' => 'server is full' }, response)
	end

	def test_send_message_without_login
		print "\ntest_send_message_without_login "
		@port = 99994
		run_server_in_background
		@socket = TCPSocket.open @host, @port

		request = { 'type' => MESSAGE_FIELD }.to_json
		@socket.puts request
		response = JSON.parse @socket.gets
		assert_equal({ 'type' => MESSAGE_FIELD, 'error' => 'you are not logged' }, response)
	end

	def test_twice_logged
		print "\ntest_twice_logged "
		@port = 99982
		run_server_in_background
		@socket = TCPSocket.open @host, @port

		request = { 'type' => MESSAGE_LOGIN }.to_json
		@socket.puts request
		@socket.gets
		
		request = { 'type' => MESSAGE_LOGIN }.to_json
		@socket.puts request
		response = JSON.parse @socket.gets
		assert_equal({ 'type' => MESSAGE_LOGIN, 'error' => 'you are already logged' }, response)
	end

	def test_illegal_message
		print "\ntest_illegal_message "
		@port = 99981
		run_server_in_background
		@socket = TCPSocket.open @host, @port

		request = { 'type' => MESSAGE_LOGIN }.to_json
		@socket.puts request
		@socket.gets

		request = { 'type' => 12345 }.to_json
		@socket.puts request
		response = JSON.parse @socket.gets
		assert_equal({ 'type' => 12345, 'error' => 'illegal request' }, response)
	end

	def test_illegal_message_without_login
		print "\ntest_illegal_message_without_login "
		@port = 99986
		run_server_in_background
		@socket = TCPSocket.open @host, @port

		request = { 'type' => 12345 }.to_json
		@socket.puts request
		response = JSON.parse @socket.gets
		assert_equal({ 'type' => 12345, 'error' => 'you are not logged' }, response)
	end

	def test_get_field
		print "\ntest_get_field "
		@port = 99999
		run_server_in_background
		@socket = TCPSocket.open @host, @port

		@socket.puts({ 'type' => MESSAGE_LOGIN }.to_json)
		@socket.gets

		request = { 'type' => MESSAGE_FIELD }.to_json
		@socket.puts request
		response_json = @socket.gets
		response = JSON.parse response_json
		assert_equal({ 'type' => MESSAGE_FIELD, 'cells' => [] }, response)
	end

	def test_step
		print "\ntest_step "
		@port = 99977
		run_server_in_background
		
		@socket1 = TCPSocket.open @host, @port
		@socket1.puts({ 'type' => MESSAGE_LOGIN }.to_json)
		@socket1.gets

		@socket2 = TCPSocket.open @host, @port
		@socket2.puts({ 'type' => MESSAGE_LOGIN }.to_json)
		@socket2.gets

		request = { 'type' => MESSAGE_STEP, 'row' => 1, 'col' => 2, 'value' => X }.to_json
		@socket1.puts request
		response = JSON.parse @socket1.gets
		assert_equal({ 'type' => MESSAGE_STEP, 'row' => 1, 'col' => 2, 'value' => X, 'success' => true, 'who_win' => nil }, response)

		response = JSON.parse @socket2.gets
		assert_equal({ 'type' => MESSAGE_STEP_OPPONENT, 'row' => 1, 'col' => 2, 'value' => X, 'who_win' => nil }, response)
	end

	def test_wrong_step
		print "\ntest_wrong_step "
		@port = 99978
		run_server_in_background
		
		@socket1 = TCPSocket.open @host, @port
		@socket1.puts({ 'type' => MESSAGE_LOGIN }.to_json)
		@socket1.gets

		@socket2 = TCPSocket.open @host, @port
		@socket2.puts({ 'type' => MESSAGE_LOGIN }.to_json)
		@socket2.gets

		request = { 'type' => MESSAGE_STEP, 'row' => -1, 'col' => 2, 'value' => X }.to_json
		@socket1.puts request
		response = JSON.parse @socket1.gets
		assert_equal({ 'type' => MESSAGE_STEP, 'row' => -1, 'col' => 2, 'value' => X, 'success' => false, 'who_win' => nil }, response)

		assert_false socket_ready? @socket2
	end

	def test_wrong_message
		print "\ntest_wrong_message "
		@port = 99946
		run_server_in_background
		@socket = TCPSocket.open @host, @port

		request = { 'type' => MESSAGE_LOGIN }.to_json
		@socket.puts request
		@socket.gets

		request = { }.to_json
		@socket.puts request
		response = JSON.parse @socket.gets
		
		assert_equal({ 'type' => nil, 'error' => 'illegal request' }, response)
	end

	def test_send_not_json
		print "\ntest_send_not_json "
		@port = 99945
		run_server_in_background
		@socket = TCPSocket.open @host, @port

		request = { 'type' => MESSAGE_LOGIN }.to_json
		@socket.puts request
		@socket.gets

		@socket.puts "not a json !"
		response = JSON.parse @socket.gets
		
		assert_equal({ 'type' => nil, 'error' => 'illegal request' }, response)
	end

	def socket_ready? socket
		not IO.select([socket], nil, nil, 1) == nil
	end
end
