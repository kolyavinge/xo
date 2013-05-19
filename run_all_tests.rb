#!/usr/bin/ruby

$LOAD_PATH.unshift(Dir.pwd + '/lib')
$LOAD_PATH.unshift(Dir.pwd + '/test')

require 'test/unit'
require 'unittest'
require 'test_field'
require 'test_game'
require 'test_xoserver' # эти тесты нужно запускать от рута
