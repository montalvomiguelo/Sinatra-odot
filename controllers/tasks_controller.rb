class TasksController < ApplicationController

  get '/tasks' do
    protected!

    @tasks = Task.includes(:list).where(lists: { user_id: current_user.id })
    erb :"tasks/index"
  end

  get '/tasks/new' do
    protected!

    @lists = current_user.lists
    erb :"tasks/new"
  end

  post '/tasks' do
    protected!

    list = find_list(params[:list_id])

    task = list.tasks.new
    task.title = params[:title]

    if task.save
      redirect to('/tasks')
    else
      halt erb(:error)
    end
  end

  get '/tasks/:id' do
    protected!

    find_task

    erb :"tasks/show"
  end

  get '/tasks/:id/edit' do
    protected!

    @task = Task.find(params[:id])
    @lists = current_user.lists

    erb :"tasks/edit"
  end

  put '/tasks/:id' do
    protected!

    find_task

    if params[:list_id]
      list = find_list(params[:list_id])
      @task.list_id = list.id
    end

    @task.title = params[:title]
    @task.duration = params[:duration] if params[:duration]

    if params[:completed] == 'true'
      @task.completed_at = Time.now unless @task.completed_at
    elsif params[:completed] == 'false'
      @task.completed_at = nil
    end

    if @task.save
      redirect to("/tasks/#{@task.id}")
    else
      halt 400, 'Invalid params'
    end
  end

  delete '/tasks/:id' do
    protected!

    find_task

    @task.destroy

    redirect to('/tasks')
  end

  private
  def find_list(id)
    begin
      list = current_user.lists.find(id)
    rescue
      halt 404, 'Not found'
    end
  end

  def find_task
    begin
      @task = Task.includes(:list).where(lists: { user_id: current_user.id }).find(params[:id])
    rescue
      halt 404, 'Not found'
    end
  end

end
