class UserSessionsController < ApplicationController

  get '/sessions/login' do
    erb :"sessions/login"
  end

  post '/sessions' do
    email = params[:email]
    password = params[:password]

    user = User.find_by(email: email).try(:authenticate, password)

    if user
      session[:id] = user.id
      redirect "/lists"
    else
      redirect to('/sessions/login')
    end
  end

end
