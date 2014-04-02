include ERB::Util

Thread.abort_on_exception = true

Thread.new {
  EventMachine.run {
    #Maps feedIDs to channels
    @channelMap = {}
    #Maps WebSockets to channels
    @socketMap = {}
    #Maps WebSockets to ids
    @sidMap = {}
    #Maps transmitters to arrays of channels, to which they send data
    @transmittersMap = {}

    EventMachine::WebSocket.start(:host => '0.0.0.0', :port => '8080') do |ws|
      ws.onopen do |handshake|
        login(handshake, ws)
      end

      ws.onclose do
        if @socketMap[ws]
          @socketMap[ws].unsubscribe(@sidMap[ws])
          @socketMap.delete(ws)
          @sidMap.delete(ws)
        end
        if @transmittersMap[ws]
          @transmittersMap.delete(ws)
        end
        puts "close"
      end

      ws.onmessage do |msg|
        if @transmittersMap[ws]
          channels = @transmittersMap[ws]
          if channels
            channels.each do |channel|
              channel.push(msg)
            end
          end
        end
      end

      ws.onerror do |error|
        puts error.to_json
      end
    end
  }
}

private

def login(handshake, ws)
  uri = URI(handshake.path)
  query = handshake.query
  path = uri.path.split('/')
  login_type = path[1]
  if login_type == 'user'
    puts query
    user = User.find_by_username(query['username'])
    unless user && user.password == query['password']
      ws.send({:code => 3, :messages => ['Wrong username or password']}.to_json)
      ws.close
      return
    end
    connection_type = path[2]
    if connection_type == 'read'
      feed_id = path[3]
      feed = Feed.find_by_identifier(feed_id)
      unless feed
        ws.send({:code => 4, :messages => ["Feed with id '#{feed_id}' does not exist"]}.to_json)
        ws.close
        return
      end
      unless feed.readers.find_by_user_id(user.id)
        ws.send({:code => 4, :messages => ["Feed #{feed.name} can't be read"]}.to_json)
        ws.close
        return
      end
      if @channelMap[feed_id]
        sid = @channelMap[feed_id].subscribe { |msg| ws.send(msg) }
      else
        channel = EventMachine::Channel.new
        sid = channel.subscribe { |msg| ws.send(msg) }
        @channelMap.merge!(feed_id => channel)
      end
      @socketMap.merge!(ws => @channelMap[feed_id])
      @sidMap.merge!(ws => sid)
    elsif connection_type == 'write'
      feed_ids = query['feed_ids'].split(',')
      channels = Array.new
      feed_ids.each do |feed_id|
        feed = Feed.find_by_identifier(feed_id)
        unless feed
          ws.send({:code => 4, :messages => ["Feed with id '#{feed_id}' does not exist"]}.to_json)
          next
        end
        unless feed.writers.find_by_user_id(user.id)
          ws.send({:code => 3, :messages => ["#{feed.name} can't be written"]}.to_json)
          next
        end
        unless @channelMap[feed_id]
          channel = EventMachine::Channel.new
          @channelMap.merge!(feed_id => channel)
        end
        channel = @channelMap[feed_id]
        channels.push(channel)
      end
      @transmittersMap.merge!(ws => channels)
    else
      ws.send({:code => 1, :messages => ["Unknown connection type: #{connection_type}"]}.to_json)
      ws.close
    end
  elsif login_type == 'device'
    puts 'login device'
  else
    ws.close
  end

end
