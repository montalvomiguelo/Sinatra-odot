require_relative '../../models/list'
require_relative '../../models/task'
require_relative '../../models/user'

module Api
  class ApplicationController < Sinatra::Base
    attr_reader :current_user

    register Sinatra::ActiveRecordExtension
    register Sinatra::Namespace
    use Rack::MethodOverride
    use Rack::PostBodyContentTypeParser

    helpers do
      def protected!
        return if authorized?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, {'Content-Type' => 'application/json'}, 'Not authorized'
      end

      def authenticate_user(credentials)
        email = credentials[0]
        password = credentials[1]
        user = User.find_by(email: email).try(:authenticate, password)
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        return false unless @auth.provided?
        return false unless @auth.basic?
        return false unless @auth.credentials
        return false unless authenticate_user(@auth.credentials)

        email = @auth.credentials[0]
        @current_user ||= User.find_by(email: email)

        return true
      end
    end
  end
end
