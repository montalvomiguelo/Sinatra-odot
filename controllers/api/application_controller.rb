require_relative '../../models/list'
require_relative '../../models/task'
require_relative '../../models/user'

module Api
  class ApplicationController < Sinatra::Base
    register Sinatra::ActiveRecordExtension
    register Sinatra::Namespace
    use Rack::MethodOverride
    use Rack::PostBodyContentTypeParser
  end
end
