class Todo < Sinatra::Base
  get '/test' do
    return 'The application is running'
  end

  get '/' do
    @todo_lists = TodoList.all
    erb :"lists/index"
  end

  get '/lists/new' do
    erb :"lists/new"
  end

  post '/lists' do
    todo_list = TodoList.new
    todo_list.title = params[:title]

    if todo_list.save
      redirect to('/')
    else
      halt erb(:error)
    end
  end
end
