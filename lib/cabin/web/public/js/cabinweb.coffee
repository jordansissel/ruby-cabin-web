class ForeverSocket
  constructor: (url) ->
    @url = url
    @connect()
    @callback = {}

  connect: () ->
    console.log("Connecting to " + @url)
    @ws = new WebSocket(@url)
    @setup()
  # connect

  onmessage: (callback) -> 
    @callback.message = callback
    @ws.onmessage = callback
  onerror: (callback) -> 
    @callback.error = callback
    @ws.onerror = callback
  onclose: (callback) -> 
    @callback.close = callback
    @ws.onclose = callback

  setup: () ->
    @ws.onerror = (error) =>
      @callback.error(event) if @callback.error?
      @reconnect()
    @ws.onclose = (event) =>
      @callback.close(event) if @callback.close?
      @reconnect()
    @ws.onmessage = (event) =>
      @callback.message(event) if @callback.message?
  # setup

  reconnect: () ->
    console.log("Reconnecting")
    callback = () => @connect()
    setTimeout(callback, 1000);
  # reconnect

class EventStream
  MAX_EVENTS_DISPLAYED: () -> 10

  constructor: () ->
    @ws = new ForeverSocket("ws://" + document.location.host + "/logs/stream")
    events = $("ul.events")
    @ws.onmessage((event) =>
      entry = jQuery("<li>")
      entry.text(event.data)
      events.append(entry)
      children = events.children()
      if children.size() > @MAX_EVENTS_DISPLAYED()
        children.first().remove()
    ) # ws.onmessage
  # constructor
# class EventStream

new EventStream
