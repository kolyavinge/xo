#!/usr/bin/ruby

$LOAD_PATH.unshift('./lib')

require 'Qt4'
require 'xoserver'
require 'proxy'
require 'main_presenter'
require 'main_view'

host = 'localhost'
port = 12345

server = XOServer.new port
Thread.start { server.run }
sleep 0.1

main_presenter1 = MainPresenter.new
main_presenter1.connect host, port
sleep 0.1

main_presenter2 = MainPresenter.new
main_presenter2.connect host, port
sleep 0.1

app = Qt::Application.new(ARGV)

main_view1 = MainView.new
main_view1.presenter = main_presenter1
main_view1.setGeometry 200, 200, 600, 500
main_view1.show

main_view2 = MainView.new
main_view2.presenter = main_presenter2
main_view2.setGeometry 900, 200, 600, 500
main_view2.show

app.exec
