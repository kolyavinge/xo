#!/usr/bin/ruby

$LOAD_PATH.unshift('../lib')
$LOAD_PATH.unshift('.')

require 'unittest'
require 'contracts'
require 'main_presenter'

class MainPresenterTest < Test::Unit::TestCase

	def IGNORE_test_connect
		presenter = MainPresenter.new
		host = 'localhost'
		port = 12345
		presenter.connect host, port
		
	end
end
