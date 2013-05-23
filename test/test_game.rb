require 'unittest'
require 'contracts'
require 'field'
require 'game'

class GameTest < Test::Unit::TestCase
	def test_init
		game = Game.new
		assert_not_nil game.field
		assert_equal X, game.whose_step
	end

	def test_step
		game = Game.new
		game.step 1, 2, X
		assert_true game.field.cells.any?{ |c| c.row == 1 && c.col == 2 && c.value == X }
		game.step 4, 1, O
		assert_true game.field.cells.any?{ |c| c.row == 4 && c.col == 1 && c.value == O }
	end

	def test_step_in_not_empty_cell
		game = Game.new
		assert_true(game.step 1, 2, X)
		assert_equal O, game.whose_step
		assert_false(game.step 1, 2, O)
		assert_equal O, game.whose_step
	end

	def test_wrong_step_twice_x
		game = Game.new
		assert_true(game.step 1, 2, X)
		assert_false(game.step 1, 3, X)
	end

	def test_wrong_step
		game = Game.new
		assert_false(game.step -1, -2, X)
	end

	def test_end_game
		game = Game.new
		
		game.step 0, 0, X
		game.step 1, 0, O

		game.step 0, 1, X
		game.step 1, 1, O

		game.step 0, 2, X
		game.step 1, 2, O

		game.step 0, 3, X
		game.step 1, 3, O

		game.step 0, 4, X
		
		assert_equal X, game.who_win

		assert_false(game.step 0, 5, O)
		assert_false(game.step 0, 6, X)
		assert_nil game.whose_step
	end
end
