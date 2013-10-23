require 'sinatra/base'
require 'sinatra/respond_to'

module QA
  class Server < Sinatra::Base
    Server.register Sinatra::RespondTo
    dir = File.dirname(File.expand_path(__FILE__))
    set :views,  "#{dir}/server/views"

    get '/wiki' do
      "Hello World"
    end

  end
end
