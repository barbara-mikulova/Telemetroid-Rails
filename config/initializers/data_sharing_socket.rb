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

    @socket_to_device_name = {}
    @socket_to_owner_name = {}

    EventMachine::WebSocket.start(:host => '0.0.0.0', :port => '8080', :debug => true) do |ws|
      ws.onopen do |handshake|
        login_data(handshake, ws)
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
            message = JSON.parse(msg)
            message.delete('device_id')
            message['deviceName'] = @socket_to_device_name[ws]
            message['owner'] = @socket_to_owner_name[ws]
            puts channels.size
            channels.each do |channel|
              channel.push(message.to_json)
            end
          end
        end
      end

      ws.onerror do |error|
        puts error.to_json
      end
    end

    @device_id_to_read_socket = {}
    @device_id_to_write_socket = {}
    @read_socket_to_device_id = {}
    @write_socket_to_device_id = {}

    EventMachine::WebSocket.start(:host => '0.0.0.0', :port => '8081') do |ws|
      ws.onopen do |handshake|
        login_messages(handshake, ws)
        puts 'login'
      end

      ws.onclose do
        if @read_socket_to_device_id[ws]
          device_identifier = @read_socket_to_device_id[ws]
          @read_socket_to_device_id.delete(ws)
          @device_id_to_read_socket.delete(device_identifier)
        elsif @write_socket_to_device_id[ws]
          device_identifier = @write_socket_to_device_id[ws]
          @write_socket_to_device_id.delete(ws)
          @device_id_to_write_socket.delete(device_identifier)
        end
        puts 'close'
      end

      ws.onmessage do |msg|
        if @read_socket_to_device_id[ws]
          device_identifier = @read_socket_to_device_id[ws]
          if @device_id_to_write_socket[device_identifier]
            @device_id_to_write_socket[device_identifier].send(msg)
          end
        elsif @write_socket_to_device_id[ws]
          device_identifier = @write_socket_to_device_id[ws]
          if @device_id_to_read_socket[device_identifier]
            @device_id_to_read_socket[device_identifier].send(msg)
          end
        end
        puts msg
      end

      ws.onerror do |error|
        puts error.to_json
      end
    end
  }
}

private


def login_data(handshake, ws)
  uri = URI(handshake.path)
  query = handshake.query
  path = uri.path.split('/')
  connection_type = path[1]
  if connection_type == 'read'
    user = User.find_by_username(query['username'])
    unless user && user.password == query['password']
      ws.send({:code => 4, :messages => ["User with username '#{query['username']}' does not exist"]}.to_json)
      ws.close
      return
    end
    feed_id = path[2]
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
    device = Device.find_by_identifier(query['identifier'])
    unless device && device.password == query['password']
      ws.send({:code => 4, :messages => ['Wrong identifier or password']}.to_json)
      ws.close
      return
    end
    feed_ids = query['feed_ids'].split(',')
    channels = []
    feed_ids.each do |feed_id|
      feed = Feed.find_by_identifier(feed_id)
      unless feed
        ws.send({:code => 4, :messages => ["Feed with id '#{feed_id}' does not exist"]}.to_json)
        next
      end
      unless feed.writing_devices.find_by_device_id(device.id)
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
    if channels.size == 0
      ws.send({:code => 3, :messages => ['No feeds can be written']}.to_json)
      ws.close
      return
    end
    @socket_to_device_name[ws] = device.name
    @socket_to_owner_name[ws] = device.user.username
    @transmittersMap[ws] = channels
  else
    ws.close
  end
end

def login_messages(handshake, ws)
  uri = URI(handshake.path)
  query = handshake.query
  path = uri.path.split('/')
  login_type = path[1]
  if login_type == 'read'
    device = Device.find_by_identifier(query['identifier'])
    unless device
      ws.send({:code => 4, :messages => ["Can't find device with identifier '#{query['identifier']}'"]}.to_json)
      ws.close
      return
    end
    unless device.password == query['password']
      puts query['password'] + "  " + device.password
      ws.send({:code => 3, :messages => ['Wrong identifier or password']}.to_json)
      ws.close
      return
    end
    @device_id_to_read_socket.merge!(device.identifier => ws)
    @read_socket_to_device_id.merge!(ws => device.identifier)
  end
  if login_type == 'write'
    user = User.find_by_username(query['username'])
    unless user
      ws.send({:code => 4, :messages => ["Can't find user with username '#{query['username']}'"]}.to_json)
      ws.close
      return
    end
    unless user.password == query['password']
      ws.send({:code => 3, :messages => ['Wrong username or password']}.to_json)
      ws.close
      return
    end
    device = Device.find_by_identifier(query['identifier'])
    unless device
      ws.send({:code => 4, :messages => ["Can't find device with identifier '#{query['identifier']}'"]}.to_json)
      ws.close
      return
    end
    unless device.user_id == user.id
      ws.send({:code => 3, :messages => ['Only allowed to owner']}.to_json)
      ws.close
    end
    unless @device_id_to_read_socket[device.identifier]
      ws.send({:code => 4, :messages => ["Device '#{device.name}' is not enabled for remote tracking"]}.to_json)
      ws.close
      return
    end
    @device_id_to_write_socket.merge!(device.identifier => ws)
    @write_socket_to_device_id.merge!(ws => device.identifier)
  end
end
