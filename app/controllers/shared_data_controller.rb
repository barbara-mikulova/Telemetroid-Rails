class SharedDataController < ApplicationController

  protect_from_forgery :except => [:full_index, :insert]

  before_action :require_login

  before_action :get_writable_feeds, :only => [:insert]

  before_action :can_read, :only => [:get_from_id]

  def full_index
    data = SharedData.all
    render json: data
  end

  def insert
    entries = params[:entries]
    track_id = get_track_id
    if @errors.length > 0
      if @feeds.length > 0
        text = 'Write successful only for feeds: '
        @feeds.each do |feed|
          text += feed.name + ', '
        end
        text = text[0..-3]
        @errors += [text]
      end
    end
    if @feeds.length > 0
      entries.each do |entry|
        new_data = SharedData.new
        new_data.json_data = entry['data']
        new_data.time_stamp = entry['timeStamp']
        new_data.device = @device
        new_data.track_id = track_id
        new_data.feeds += @feeds
        if new_data.save
          @device.save
        end
      end
    end
    if @errors.length > 0
      error_denied(@errors)
    else
      response_ok
    end
  end

  def get_from_id
    data = @feed.shared_datas.where('shared_data.id >= ?', params[:id])
    render json: data
  end

  def can_read
    @feed = Feed.find_by_identifier(params[:identifier])
    unless @feed
      error_missing_entry(["Can't find feed with identifier: " + params[:identifier]])
    end
    if (session[:type] == 'user') and (@feed.readers.find_by_user_id([session[:id]]) == nil)
      error_denied(["Can't read from feed. Ask administrator for permission"])
    end
  end

  def get_writable_feeds
    feed_ids = params[:feedsIdentifiers]
    @feeds = Array.new
    @errors = Array.new
    @device = Device.find_by_identifier(params[:deviceIdentifier])
    unless @device
      cant_find_device
      return
    end
    feed_ids.each do |feed_id|
      feed = Feed.find_by_identifier(feed_id)
      unless feed
        error_missing_entry(["Can't find feed with identifier: " + feed_id])
        return
      end
      if (session[:type] == 'user') and (feed.writers.find_by_user_id(session[:id]) != nil)
        @feeds.push(feed)
      else
        @errors += ["Can't write to " + feed.name + '. Ask administrator for permission.']
      end
    end
  end

  private
  def cant_find_device
    error_missing_entry(["Can't find device with identifier: " + params[:deviceIdentifier]])

  end

  def get_track_id
    type = params[:trackType]
    if type == 'standalone'
      return -1
    end
    if type == 'new'
      @device.current_track += 1
      return @device.current_track
    end
    return @device.current_track
  end
end

