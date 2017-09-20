require 'sinatra/base'

class Todo < Sinatra::Base
  get '/test' do
    'The application is running'
  end
end
