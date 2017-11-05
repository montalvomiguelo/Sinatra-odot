class UsersController < ApplicationController

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
      session[:id] = @user.id
      redirect "/lists"
    else
      halt 400, 'Invalid data'
    end
  end

end
