
require 'game'
require 'socket'
require 'json'

XOSERVER_LOCK_FILE = "/var/run/xo.pid"
XOSERVER_DEFAULT_PORT = 4554

class XOServer

	def initialize port=XOSERVER_DEFAULT_PORT
		@port = port
		@game = Game.new
	end

	def run
		return false if not first_run?

		@server = TCPServer.open @port
		Thread.start {
			loop {
			  client = @server.accept
			  request = JSON.parse client.gets
			  responce = proccess request
			  client.puts responce.to_json
			  client.close
			}
		}

		return true
	end

	def stop
		@server.close if @server != nil
	end

	private

	def proccess request
		responce = { 'type' => request['type'] }
		if request['type'] == XOREQUEST_GET_FIELD
			responce['cells'] = @game.field.to_a
		elsif request['type'] == XOREQUEST_STEP
			row = request['row']
			col = request['col']
			value = request['value']
			success = @game.step row, col, value
			responce['success'] = success
			responce['who_win'] = @game.who_win
		end

		return responce
	end

	def first_run?
		if not File.exist? XOSERVER_LOCK_FILE
			write_pid_to_lock_file
			try_lock_file
		else # lock file exist
			if try_lock_file
				write_pid_to_lock_file
			else
				return false
			end
		end

		return true
	end

	def try_lock_file
		File.new(XOSERVER_LOCK_FILE).flock(File::LOCK_NB | File::LOCK_EX)
	end

	def write_pid_to_lock_file
		File.open(XOSERVER_LOCK_FILE, 'w'){ |file| file << Process.pid }
	end
end
