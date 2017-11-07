module Api
  class TasksController < Api::ApplicationController
    get '/tasks' do
      json Task.all
    end

    get '/tasks/:id' do
      task = find_task(params[:id])
      json task
    end

    post '/tasks' do
      task = Task.new

      task.title = params[:title]
      task.list_id = params[:list_id]

      if task.save
        json task
      else
        status 422
        json task.errors
      end
    end

    put '/tasks/:id' do
      task = find_task(params[:id])

      task.title = params[:title]
      task.list_id = params[:list_id] if params[:list_id]
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
        Task.find(id)
      rescue
        halt 404, {'Content-Type' => 'application/json'}, 'Not found'
      end
    end

  end
end
