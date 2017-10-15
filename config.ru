require 'bundler'
Bundler.require

ENV['RACK_ENV'] ||= 'development'

require_relative 'app'

run App
