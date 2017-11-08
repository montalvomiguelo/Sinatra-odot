module Api

  class ListsController < Api::ApplicationController
    before do
      protected!
    end

    post '/lists' do
      list = current_user.lists.new
      list.title = params[:title]

      if list.save
        json list
      else
        status 422
        json list.errors
      end
    end

    get '/lists/:id' do
      list = find_list(params[:id])
      json list.as_json(include: :tasks)
    end

    get '/lists' do
      json current_user.lists.all
    end

    delete '/lists/:id' do
      list = find_list(params[:id])

      list.destroy

      return [200, {'Content-Type' => 'application/json'}, ['List deleted successfully']]
    end

    put '/lists/:id' do
      list = find_list(params[:id])

      list.title = params[:title]

      if list.save
        json list
      else
        status 422
        json list.errors
      end

    end


    private
    def find_list(id)
      begin
        current_user.lists.find(params[:id])
      rescue
        halt 404, {'Content-Type' => 'application/json'}, 'Not found'
      end
    end

  end

end
