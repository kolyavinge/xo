require 'field'

class Game

	attr_reader :field, :whose_step, :who_win

	def initialize
		@field = Field.new 20, 5
		@whose_step = X
	end

	def step row, col, value
		return false if @who_win != nil
		return false if value != @whose_step
		result = field.step row, col, @whose_step
		if result == true
			@who_win = @field.find_winner
			if @who_win != nil
				@whose_step = nil
			else
				@whose_step = if @whose_step == X then O else X end
			end
			return true
		else
			return false
		end
	end
end
