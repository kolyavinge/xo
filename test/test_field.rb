require 'unittest'
require 'field'

class FieldTest < Test::Unit::TestCase
	def test_init
		field = Field.new 10, 4
		assert_equal 10, field.size
		assert_equal 100, field.cells.length
		assert_true field.cells.all?{ |cell| cell.value == CELL_EMPTY }
		(0...10).each{ |r|
			(0...10).each{ |c|
				assert_true(field.cells.any? { |cell| cell.row == r && cell.col == c })
			}
		}
	end

	def test_get_cell
		field = Field.new 10, 4
		cell = field.get_cell 2, 4
		assert_true cell != nil
		cell = field.get_cell -1, 4
		assert_true cell == nil
	end

	def test_step_in_empty_cell
		field = Field.new 10, 4
		result = field.step 1, 3, X
		assert_true result
		assert_true field.cells.any? { |cell| cell.row == 1 && cell.col == 3 && cell.value == X }
	end

	def test_step_in_not_empty_cell
		field = Field.new 10, 4
		field.step 1, 3, X
		result = field.step 1, 3, O
		assert_false result
	end

	def test_find_winner_horizont
		field = Field.new 10, 4
		field.step 1, 3, X
		field.step 1, 2, X
		field.step 1, 1, X
		assert_equal nil, field.find_winner
		field.step 1, 0, X
		assert_equal X, field.find_winner
	end

	def test_find_winner_vertical
		field = Field.new 10, 4
		field.step 2, 1, O
		field.step 4, 1, O
		field.step 3, 1, O
		assert_equal nil, field.find_winner
		field.step 1, 1, O
		assert_equal O, field.find_winner
	end
end
