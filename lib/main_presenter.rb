require 'proxy'

class MainPresenter

	attr_reader :field, :field_size, :xo
	attr_accessor :update_event

	def connect host, port
		@field = []
	
		@proxy = Proxy.new(host, port)
	
		@proxy.login_completed = Proc.new { |response|
			if response['error'] != nil
				print response['error']
			else
				@xo = response['xo']
				@field_size = response['size']
			end
		}
		
		@proxy.get_field_completed = Proc.new { |response|
			if response['error'] != nil
				print response['error']
			else
				@field = response['cells']
				raise_update
			end
		}
		
		@proxy.step_completed = Proc.new { |response|
			print "client: step_completed (#{@xo})\n"
			if response['error'] != nil
				print response['error']
			else
				if response['success'] == true
					@field << {
						'row'   => response['row'],
						'col'   => response['col'],
						'value' => response['value']
					}
					raise_update
				end
			end
		}
		
		@proxy.opponent_step_completed = Proc.new { |response|
			print "client: opponent_step_completed (#{@xo})\n"
			if response['error'] != nil
				print response['error']
			else
				@field << {
					'row'   => response['row'],
					'col'   => response['col'],
					'value' => response['value']
				}
				raise_update
			end
		}
	
		@proxy.login
	end

	def step row, col
		print "step: row=#{row}, col=#{col}, value=#{@xo}\n"
		@proxy.step row, col, @xo
	end
	
	private

	def raise_update
		@update_event.call unless @update_event == nil
	end
end
