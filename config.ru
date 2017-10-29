require 'bundler'
Bundler.require

ENV['RACK_ENV'] ||= 'development'

Dir[File.join(File.dirname(__FILE__), 'controllers', '*.rb')].each { |controller| require controller }

use TasksController
use UsersController
use UserSessionsController
use PasswordResetsController

run ListsController
