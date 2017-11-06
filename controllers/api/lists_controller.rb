module Api

  class ListsController < Api::ApplicationController
    namespace '/api' do

      post '/lists' do
        list = List.new
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
        json list
      end

      get '/lists' do
        json List.all
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

    end

    private
    def find_list(id)
      begin
        List.find(params[:id])
      rescue
        halt 404, {'Content-Type' => 'application/json'}, 'Not found'
      end
    end

  end

end
