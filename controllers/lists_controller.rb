class ListsController < ApplicationController

  get '/lists' do
    protected!

    @lists = current_user.lists.all.preload(:tasks)

    erb :"lists/index"
  end

  get '/lists/new' do
    protected!

    erb :"lists/new"
  end

  get '/lists/:id/edit' do
    protected!

    find_list(params[:id])

    erb :"lists/edit"
  end

  get '/lists/:id' do
    protected!

    find_list(params[:id])

    erb :"lists/show"
  end

  put '/lists/:id' do
    protected!

    find_list(params[:id])

    @list.title = params[:title]

    if @list.save
      redirect "/lists/#{@list.id}"
    else
      halt 400, 'Invalid params'
    end
  end

  post '/lists' do
    protected!

    list = List.new
    list.title = params[:title]
    list.user_id = current_user.id

    if list.save
      redirect to('/lists')
    else
      halt 400, 'Invalid params'
    end
  end

  delete '/lists/:id' do
    protected!

    find_list(params[:id])

    @list.destroy

    redirect to('/lists')
  end

  private
  def find_list(id)
    begin
      @list = current_user.lists.find(params[:id])
    rescue
      halt 404, 'Not found'
    end
  end

end
