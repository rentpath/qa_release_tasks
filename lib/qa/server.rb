require 'sinatra/base'
require 'sinatra/respond_to'

module QA
  class Server < Sinatra::Base
    Server.register Sinatra::RespondTo
    dir = File.dirname(File.expand_path(__FILE__))
    set :views,  "#{dir}/server/views"

    get '/wiki' do
      gitwiki = Git::Wiki.new
      @username = ''
      @password = ''
      @date = Date.today.strftime
      @tags = gitwiki.get_tag_options
      @starttag = default_starttag
      @endtag = default_endtag
      erb :wiki_form
    end

    private

    def default_starttag
      @tags[0]
    end

    def default_endtag
      @tags[1]
    end

  end
end
