module Api
  class TasksController < Api::ApplicationController
    before do
      protected!
    end

    get '/tasks' do
      @tasks = Task.includes(:list).where(lists: { user_id: current_user.id })
      json @tasks
    end

    get '/tasks/:id' do
      task = find_task(params[:id])
      json task
    end

    post '/tasks' do
      task = Task.new

      task.title = params[:title]

      list = find_list(params[:list_id])
      task.list_id = list.id

      if task.save
        json task
      else
        status 422
        json task.errors
      end
    end

    put '/tasks/:id' do
      task = find_task(params[:id])

      if params[:list_id]
        list = find_list(params[:list_id])
        task.list_id = list.id
      end

      task.title = params[:title]
      task.duration = params[:duration] if params[:duration]

      if params[:completed] == 'true'
        task.completed_at = Time.now unless task.completed_at
      elsif params[:completed] == 'false'
        task.completed_at = nil
      end

      if task.save
        json task
      else
        status 422
        json task.errors
      end
    end

    delete '/tasks/:id' do
      task = find_task(params[:id])

      task.destroy

      return [200, {'Content-Type' => 'application/json'}, ['Task deleted successfully']]
    end

    private
    def find_task(id)
      begin
        Task.includes(:list).where(lists: { user_id: current_user.id }).find(id)
      rescue
        halt 404, {'Content-Type' => 'application/json'}, 'Not found'
      end
    end

    def find_list(id)
      begin
        current_user.lists.find(params[:list_id])
      rescue
        halt 404, 'Not found'
      end
    end

  end
end
