#!/usr/bin/ruby

$LOAD_PATH.unshift('./lib')

require 'Qt4'
require 'xoserver'
require 'proxy'
require 'main_presenter'
require 'main_view'

host = 'localhost'
port = 12345

main_presenter = MainPresenter.new
main_presenter.connect host, port
sleep 0.1

app = Qt::Application.new(ARGV)

main_view = MainView.new
main_view.presenter = main_presenter
main_view.setGeometry 200, 200, 600, 500
main_view.show

app.exec
