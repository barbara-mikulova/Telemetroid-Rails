include ERB::Util

Thread.abort_on_exception = true

Thread.new {
  EventMachine.run {
    @device_id_to_read_socket = {}
    @device_id_to_write_socket = {}
    @read_socket_to_device_id = {}
    @write_socket_to_device_id = {}

    EventMachine::WebSocket.start(:host => '0.0.0.0', :port => '8081') do |ws|
      ws.onopen do |handshake|
        login(handshake, ws)
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
def login(handshake, ws)
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
    @device_id_to_write_socket.merge!(device.identifier => ws)
    @write_socket_to_device_id.merge!(ws => device.identifier)
  end
end

