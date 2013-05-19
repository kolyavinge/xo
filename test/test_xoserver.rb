require 'unittest'
require 'contracts'
require 'json'
require 'xoserver'

class XOServerTest < Test::Unit::TestCase
	def setup
		@host = 'localhost'
		File.delete XOSERVER_LOCK_FILE if File.exist? XOSERVER_LOCK_FILE
	end

	def teardown
		@server.stop if @server != nil
		@socket.close if @socket != nil
	end

	def test_lock_file
		@server = XOServer.new
		assert_true @server.run
		assert_true(File.exist?(XOSERVER_LOCK_FILE))
	end

	def test_run_single_instance
		@server = XOServer.new
		assert_true @server.run
		assert_false @server.run
	end

	def test_run_single_instance_2
		@port = 99997
		assert_true XOServer.new(@port).run
		assert_false XOServer.new(@port).run
	end

	# integration tests

	def test_get_field
		@port = 99999
		@server = XOServer.new @port
		@server.run
		request = { 'type' => XOREQUEST_GET_FIELD }.to_json
		@socket = TCPSocket.open @host, @port
		@socket.puts request
		@socket.flush
		response_json = @socket.gets
		response = JSON.parse response_json
		assert_equal XOREQUEST_GET_FIELD, response['type']
		assert_equal [], response['cells']
	end

	def test_step
		@port = 99998
		@server = XOServer.new @port
		@server.run
		request = { 'type' => XOREQUEST_STEP, 'row' => 1, 'col' => 2, 'value' => X }.to_json
		@socket = TCPSocket.open @host, @port
		@socket.puts request
		@socket.flush
		response_json = @socket.gets
		response = JSON.parse response_json
		assert_equal XOREQUEST_STEP, response['type']
		assert_equal true, response['success']
		assert_equal nil, response['who_win']
	end
end
