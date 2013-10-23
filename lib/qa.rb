require 'qa/server'

module QA
  class << self
    def new
      Server.new
    end

    def rack_app(path)
      Rack::Builder.new {
        map(path) { run QA.new }
      }.to_app
    end
  end
end
