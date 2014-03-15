include ERB::Util

Thread.abort_on_exception = true

Thread.new {
  EventMachine.run {
    @sockets = Array.new
    EventMachine::WebSocket.start(:host => '0.0.0.0', :port => '8080') do |ws|
      ws.onopen do
        @sockets.push(ws)
      end

      ws.onclose do
        puts "close"
      end

      ws.onmessage do |msg|
        puts msg
        @sockets.each do |socket|
          socket.send(msg)
        end
      end
    end
  }
}