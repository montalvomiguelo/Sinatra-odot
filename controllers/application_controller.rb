require_relative '../models/list'
require_relative '../models/task'
require_relative '../models/user'

class ApplicationController < Sinatra::Base
  enable :sessions

  register Sinatra::ActiveRecordExtension

  use Rack::MethodOverride

  use Rack::Protection::AuthenticityToken

  set :views, File.expand_path('../../views', __FILE__)

  configure do
  end

  helpers do
    def current_user
      @current_user ||= User.find(session[:id]) if session[:id]
    end

    def protected!
      return if current_user
      halt 401, "Not authorized\n"
    end

    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://{request.env['HTTP_HOST']}"
    end
  end
end
