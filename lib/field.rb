require 'contracts'

class Cell

	attr_accessor :row, :col, :value
	
	def initialize row, col, value
		@row = row
		@col = col
		@value = value
	end

	def to_hash
		{'row' => @row, 'col' => @col, 'value' => @value}
	end
end

class Field

	attr_accessor :size, :cells

	def initialize size, line_length
		@line_length = line_length
		@size = size
		@cells = []
		(0...@size).each{ |r|
			(0...@size).each{ |c|
				@cells << Cell.new(r, c, CELL_EMPTY)
			}
		}
	end

	def step row, col, value
		cell = get_cell row, col
		if cell != nil && cell.value == CELL_EMPTY
			cell.value = value
			@last_cell = cell
			return true
		else
			return false
		end
	end

	def get_cell row, col
		@cells.find { |cell| cell.row == row && cell.col == col }
	end

	def find_winner
		return nil if @last_cell == nil
		horiz = get_line_length(0,1) + get_line_length(0,-1) + 1
		return @last_cell.value if horiz >= @line_length
		vert = get_line_length(1,0) + get_line_length(-1,0) + 1
		return @last_cell.value if vert >= @line_length
		return nil
	end

	def to_a
		@cells.select{ |cell| cell.value != CELL_EMPTY }.map{ |cell| cell.to_hash }
	end

	private

	def get_line_length dr, dc
		count = 0
		row, col = @last_cell.row + dr, @last_cell.col + dc
		cell = get_cell row, col
		while cell != nil && cell.value == @last_cell.value
			count += 1
			row += dr
			col += dc
			cell = get_cell row, col
		end

		return count
	end
end
