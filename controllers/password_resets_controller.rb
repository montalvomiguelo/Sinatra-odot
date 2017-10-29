require_relative 'user_sessions_controller'

class PasswordResetsController < ApplicationController
  use UserSessionsController

  get '/password_resets/new' do
    erb :"password_resets/new"
  end

  post '/password_resets' do
    @user = User.find_by(email: params[:email])

    redirect '/password_resets/new' unless @user

    @user.generate_password_reset_token!

    @base_url = request.host

    @base_url = base_url

    Pony.mail :to => @user.email,
              :from => 'me@example.com',
              :subject => 'Password reset',
              :body => erb(:email)

    redirect '/sessions/login'
  end

  get '/password_resets/:token/edit' do
    @user = User.find_by(password_reset_token: params[:token])

    redirect '/password_resets/new' unless @user

    erb :"password_resets/edit"
  end

  put '/password_resets/:token' do
    user = User.find_by(password_reset_token: params[:token])

    halt 404 unless user

    user.password = params[:password]
    user.password_reset_token = nil

    if user.save
      redirect '/sessions/login'
    else
      halt 422, "Invalid password\n"
    end
  end
end
