require 'sinatra'

class Todo < Sinatra::Base
  set :environment, ENV['RACK_ENV']

  configure do
  end

  Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each { |model| require model }

  Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |lib| load lib }
end
