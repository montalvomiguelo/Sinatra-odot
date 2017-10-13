class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :environment, ENV['RACK_ENV']

  configure do
  end

  Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each { |model| require model }

  get '/test' do
    return 'The application is running'
  end

  get '/' do
    @lists = List.all
    erb :"lists/index"
  end

  get '/lists/new' do
    erb :"lists/new"
  end

  post '/lists' do
    list = List.new
    list.title = params[:title]

    if list.save
      redirect to('/')
    else
      halt erb(:error)
    end
  end
end
