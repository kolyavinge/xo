#!/usr/bin/ruby

$LOAD_PATH.unshift('./lib')

require 'xoserver'

host = 'localhost'
port = 12345

server = XOServer.new port
server.run
