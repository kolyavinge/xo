#!/usr/bin/ruby

$LOAD_PATH.unshift('../lib')
$LOAD_PATH.unshift('.')

require 'unittest'
require 'contracts'
require 'json'
require 'xoserver'
require 'proxy'

class ProxyTest < Test::Unit::TestCase

	def setup
		@host = 'localhost'
		@actual = nil
	end

	def teardown
		@proxy.close unless @proxy == nil
		@server.stop
	end

	def run_server_in_background
		Thread.start {
			@server = XOServer.new(@port)
			@server.run
		}
		sleep 0.1
	end

	def test_login
		@port = 7777
		run_server_in_background
		@proxy = Proxy.new(@host, @port)
		@proxy.login_completed = Proc.new { |response| @actual = response }
		@proxy.login
		sleep 0.1
		expected = { 'type' => MESSAGE_LOGIN, 'xo' => X }
		assert_equal expected, @actual
	end

	def test_get_field
		@port = 7775
		run_server_in_background
		@proxy = Proxy.new(@host, @port)
		@proxy.login
		@proxy.get_field_completed = Proc.new { |response| @actual = response }
		@proxy.get_field
		sleep 0.1
		expected = { 'type' => MESSAGE_FIELD, 'cells' => [] }
		assert_equal expected, @actual
	end

	def test_step
		@port = 7774
		run_server_in_background
		@proxy = Proxy.new(@host, @port)
		@proxy.login
		@proxy.step_completed = Proc.new { |response| @actual = response }
		@proxy.step 1, 2, X
		sleep 0.1
		expected = { 'type' => MESSAGE_STEP, 'row' => 1, 'col' => 2, 'value' => X, 'success' => true, 'who_win' => nil }
		assert_equal expected, @actual
	end

	def test_opponent_step_completed
		@port = 7772
		run_server_in_background
		
		@proxy1 = Proxy.new(@host, @port)
		@proxy1.login
		
		@proxy2 = Proxy.new(@host, @port)
		@proxy2.login
		@proxy2.opponent_step_completed = Proc.new { |response| @actual = response }

		@proxy1.step 1, 2, X
		sleep 0.1

		expected = { 'type' => MESSAGE_STEP_OPPONENT, 'row' => 1, 'col' => 2, 'value' => X, 'who_win' => nil }
		assert_equal expected, @actual
	end
end
