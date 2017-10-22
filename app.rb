require_relative 'models/list'
require_relative 'models/task'
require_relative 'models/user'

class App < Sinatra::Base

  register Sinatra::ActiveRecordExtension

  set :environment, ENV['RACK_ENV']

  use Rack::MethodOverride

  configure do
  end

  get '/test' do
    return 'The application is running'
  end

  get '/lists' do
    @lists = List.all

    erb :"lists/index"
  end

  get '/lists/new' do
    erb :"lists/new"
  end

  get '/lists/:id/edit' do
    @list = List.find(params[:id])
    erb :"lists/edit"
  end

  get '/lists/:id' do
    @list = List.find(params[:id])
    erb :"lists/show"
  end

  put '/lists/:id' do
    @list = List.find(params[:id])
    @list.title = params[:title]

    if @list.save
      redirect to("/lists/#{@list.id}")
    else
      halt erb(:error)
    end
  end

  post '/lists' do
    list = List.new
    list.title = params[:title]

    if list.save
      redirect to('/lists')
    else
      halt erb(:error)
    end
  end

  delete '/lists/:id' do
    @list = List.find(params[:id])
    @list.destroy

    redirect to('/lists')
  end

  get '/tasks' do
    @tasks = Task.includes(:list)
    erb :"tasks/index"
  end

  get '/tasks/new' do
    @lists = List.all
    erb :"tasks/new"
  end

  post '/tasks' do
    task = Task.new
    task.title = params[:title]
    task.list_id = params[:list_id]

    if task.save
      redirect to('/tasks')
    else
      halt erb(:error)
    end
  end

  get '/tasks/:id' do
    @task = Task.find(params[:id])

    erb :"tasks/show"
  end

  get '/tasks/:id/edit' do
    @task = Task.find(params[:id])
    @lists = List.all

    erb :"tasks/edit"
  end

  put '/tasks/:id' do
    @task = Task.find(params[:id])
    @task.title = params[:title]
    @task.list_id = params[:list_id]
    @task.duration = params[:duration] if params[:duration]

    if params[:completed] == 'true'
      @task.completed_at = Time.now unless @task.completed_at
    elsif params[:completed] == 'false'
      @task.completed_at = nil
    end

    if @task.save
      redirect to("/tasks/#{@task.id}")
    else
      halt erb(:error)
    end
  end

  delete '/tasks/:id' do
    @task = Task.find(params[:id])
    @task.destroy

    redirect to('/tasks')
  end

  get '/users/new' do
    erb :"users/new"
  end

  post '/users' do
    @user = User.new

    @user.first_name = params[:first_name]
    @user.last_name = params[:last_name]
    @user.email = params[:email]
    @user.password = params[:password]

    if @user.save
      redirect to('/lists')
    else
      halt erb(:error)
    end
  end

end
