require "sinatra/base"
require "cabin"
require "haml"

module Cabin::Web; end
class Cabin::Web::Logs < Sinatra::Base
  # Make an echo server over websockets.
  get "/logs/stream" do
    websocket = FTW::WebSocket::Rack.new(env)
    stream(:keep_open) do |out|
      subscribe(websocket)
    end
    websocket.rack_response
  end # get /logs/stream

  get "/logs/js/*" do
    static("/js/#{params[:splat].first}")
  end # get /logs/js/*

  get "/logs/css/*" do
    static("/css/#{params[:splat].first}")
  end # get /logs/css/*

  get "/logs" do
    redirect "/logs/"
  end

  get "/logs/" do
    haml :index
  end

  helpers do
    def static(path)
      publicdir = File.join(File.dirname(__FILE__), "public")
      fullpath = File.expand_path(File.join(publicdir, path))
      if !fullpath.start_with?(publicdir)
        return [400, {}, "Bad path: #{path}"]
      end
      send_file(fullpath)
    end

    def subscribe(websocket)
      queue = Queue.new
      subscriptions = {}
      Cabin::Channel.each do |channel_id, channel|
        subscriptions[channel] = channel.subscribe(queue)
      end

      while true
        message = queue.pop
        begin
          websocket.publish(message.to_json)
        rescue Errno::EPIPE, Errno::ECONNRESET, SystemCallError
          # JRuby tosses this instead of Errno::EPIPE:
          #   #<SystemCallError: Unknown error - Broken pipe>
          #   org/jruby/RubyIO.java:1291:in `syswrite'
          #
          # If we get here, there was an error writing to the receiver. 
          # This connection's dead and gone, so return.
          return
        end
      end
    ensure
      subscriptions.each do |channel, id|
        channel.unsubscribe(id)
      end
    end
  end
end # class Cabin::Web::Logs
