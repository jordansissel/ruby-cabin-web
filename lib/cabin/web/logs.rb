require "sinatra/base"
require "cabin"

module Cabin::Web; end
class Cabin::Web::Logs < Sinatra::Base
  def subscribe(websocket)
    @channel ||= Cabin::Channel.get
    queue = Queue.new
    id = @channel.subscribe(queue)
    while true
      message = queue.pop
      begin
        websocket.publish(message.to_json)
      rescue Errno::EPIPE
        # finish since the client died or went away
        return
      end
    end
  ensure
    @channel.unsubscribe(id) if !id.nil?
    @channel.info("Unsubscribing websocket client")
  end

  get "/logs" do
    haml :index
  end # get /

  # Make an echo server over websockets.
  get "/logs/stream" do
    websocket = FTW::WebSocket::Rack.new(env)
    stream(:keep_open) do |out|
      subscribe(websocket)
    end
    websocket.rack_response
  end # get /websocket
end # class Cabin::Web::Logs
