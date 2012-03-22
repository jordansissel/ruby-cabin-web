#!/usr/bin/env ruby

require "ftw"
require "json"

agent = FTW::Agent.new
ws = agent.websocket!("http://localhost:8080/logs/stream")

ws.each do |event|
  obj = JSON.parse(event)
  p obj
end
