require "sinatra/base"

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require "ftw/websocket/rack"
require "cabin"
require "cabin/web/logs"

logger = Cabin::Channel.get
logger.level = :info
logger.subscribe(STDOUT)

class Rack::Logger
  def call(env)
    if @logger.nil?
      @logger = Cabin::Channel.get
      @logger.subscribe(env["rack.errors"])
    end

    env["rack.logger"] = @logger
    @app.call(env)
  end
end

class Example < Sinatra::Base
  get "/" do
    p logger
    Cabin::Channel.get.info("Get on /", :params => params)
    'Hello'
  end

  get "/foo" do
    Cabin::Channel.get.info("Get on /foo", :params => params)
    'foo'
  end
end

class App < Sinatra::Base
  enable :logging
  use Example
  use Cabin::Web::Logs
  use Rack::Logger
  use Rack::CommonLogger
  use Rack::Logger

  before do
    #request.logger  = Cabin::Channel.get
    env["rack.logger"] = Cabin::Channel.get
  end

  helpers do
    def logger
      request.logger
    end
  end
end

app = App.new
require "rack/handler/ftw"
Rack::Handler::FTW.run(app, :Host => "0.0.0.0", :Port => 8080)
#require "thin"
#require "rack/handler/thin"
#Rack::Handler::Thin.run(app, :Host => "0.0.0.0", :Port => 8080)
