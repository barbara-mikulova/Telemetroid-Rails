class SharedDataController < ApplicationController

  protect_from_forgery :except => [:full_index, :insert]

  def full_index
    data = SharedData.all
    render json: data
  end

  def insert
    feed_ids = params[:feedsIdentifiers]
    type = params[:trackType]
    device_id = params[:deviceIdentifier]
    entries = params[:entries]
    device = Device.find_by_identifier(device_id)
    track_id = get_track_id(device, type)
    feeds = get_feeds_from_ids(feed_ids)
    entries.each do |entry|
      new_data = SharedData.new
      new_data.json_data = entry['data']
      new_data.time_stamp = entry['timeStamp']
      new_data.device = device
      new_data.track_id = track_id
      new_data.feeds += feeds
      if new_data.save
        device.save
      end
    end
    response_ok
  end

  private
  def get_feeds_from_ids(feed_ids)
    feeds = Array.new
    feed_ids.each do |feed_id|
      feed = Feed.find_by_identifier(feed_id)
      feeds.push(feed)
    end
    return feeds
  end

  def get_track_id(device, type)
    if type == 'standalone'
      return -1
    end
    if type == 'new'
      device.current_track += 1;
      return device.current_track
    end
    return device.current_track
  end

end
