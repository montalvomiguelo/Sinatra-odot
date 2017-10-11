class Todo < Sinatra::Base
  get '/test' do
    return 'The application is running'
  end

  get '/' do
    erb :lists
  end
end
