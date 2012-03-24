require "sinatra/base"

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require "ftw/websocket/rack"
require "cabin"
require "cabin/web/logs"

class Redirector < Sinatra::Base
  get "/" do
    redirect "/logs/"
  end
end

class App < Sinatra::Base
  use Redirector # redirect / -> /logs/

  # Expose logs over websockets at /logs (browser) and /logs/stream (websocket)
  use Cabin::Web::Logs
end

# Run the webserver
Thread.new do
  app = App.new
  require "rack/handler/ftw"
  Rack::Handler::FTW.run(app, :Host => "0.0.0.0", :Port => 8080)
end

# Read from stdin, forever, logging lines from stdin.
logger = Cabin::Channel.get
logger.level = :info

# Emit to stdout as well
logger.subscribe(STDOUT)
STDIN.each_line do |line|
  logger.log(:message => line.chomp)
end

