include ERB::Util

Thread.abort_on_exception = true

Thread.new {
  EventMachine.run {
    @logged_users = Array.new
    @channelMap = {}

    EventMachine::WebSocket.start(:host => '0.0.0.0', :port => '8080') do |ws|
      ws.onopen do |handshake|
        login(handshake, ws)
        puts @channelMap
      end

      ws.onclose do
        puts "close"
      end

      ws.onmessage do |msg|
        json = JSON.parse(msg)
        puts json
        @channelMap[json['feedID']].each do |ws|
          ws.send 'send something'
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
  puts query
  path = uri.path.split('/')
  puts path.size
  if path[1] == 'user'
    user = User.find_by_username(query['username'])
    unless user && user.password == query['password']
      ws.send 'Wrong username or password'
      ws.close
      return
    end
    if path[2] == 'read'
      feed = Feed.find_by_identifier(path[3])
      unless feed
        ws.send "Feed with id '#{path[3]}' does not exist"
        ws.close
        return
      end
      unless feed.readers.find_by_user_id(user.id)
        ws.send "Feed #{feed.name} can't be read"
        ws.close
        return
      end
      if @channelMap[path[3]]
        puts 'Map contains ID'
        @channelMap[path[3]].push(ws)
      else
        puts 'Map does not contain feedID'
        @channelMap.merge!(path[3] => [ws])
      end
    elsif path[2] == 'write'
      feed_ids = query['feed_ids'].split(',')
      feed_ids.each do |feed_id|
        feed = Feed.find_by_identifier(feed_id)
        unless feed
          ws.send "Feed with id '#{feed_id}' does not exist"
        end
        unless feed.writers.find_by_user_id(user.id)
          ws.send "#{feed.name} can't be written"
        end
      end
      puts feed_ids
    end
  elsif path[1] == 'device'
    puts 'login device'
  end
end