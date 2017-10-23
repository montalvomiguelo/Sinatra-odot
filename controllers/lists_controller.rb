class ListsController < ApplicationController

  get '/lists' do
    protected!

    @lists = List.all

    erb :"lists/index"
  end

  get '/lists/new' do
    protected!

    erb :"lists/new"
  end

  get '/lists/:id/edit' do
    protected!

    @list = List.find(params[:id])
    erb :"lists/edit"
  end

  get '/lists/:id' do
    protected!

    @list = List.find(params[:id])
    erb :"lists/show"
  end

  put '/lists/:id' do
    protected!

    @list = List.find(params[:id])
    @list.title = params[:title]

    if @list.save
      redirect to("/lists/#{@list.id}")
    else
      halt erb(:error)
    end
  end

  post '/lists' do
    protected!

    list = List.new
    list.title = params[:title]

    if list.save
      redirect to('/lists')
    else
      halt erb(:error)
    end
  end

  delete '/lists/:id' do
    protected!

    @list = List.find(params[:id])
    @list.destroy

    redirect to('/lists')
  end

end
