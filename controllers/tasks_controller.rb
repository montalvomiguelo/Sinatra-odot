class TasksController < ApplicationController

  get '/tasks' do
    protected!

    @tasks = Task.includes(:list)
    erb :"tasks/index"
  end

  get '/tasks/new' do
    protected!

    @lists = List.all
    erb :"tasks/new"
  end

  post '/tasks' do
    protected!

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
    protected!

    @task = Task.find(params[:id])

    erb :"tasks/show"
  end

  get '/tasks/:id/edit' do
    protected!

    @task = Task.find(params[:id])
    @lists = List.all

    erb :"tasks/edit"
  end

  put '/tasks/:id' do
    protected!

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
    protected!

    @task = Task.find(params[:id])
    @task.destroy

    redirect to('/tasks')
  end

end
