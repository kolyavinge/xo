require 'test/unit' 

class Test::Unit::TestCase
	def assert_true expression, message=''
		assert_equal true, expression, message
	end

	def assert_false expression, message=''
		assert_equal false, expression, message
	end

	def assert_nil expression, message=''
		assert_true expression == nil, message
	end

	def assert_not_nil expression, message=''
		assert_true expression != nil, message
	end
end
