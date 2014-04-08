class TracksController < ApplicationController
  protect_from_forgery :except => [:create]
  before_action :require_user_login

  def full_index
    render json: Track.all
  end

  def create
    track = Track.new(track_params)
    feed_ids = params[:feed_identifiers].split(',')
    feeds = []
    errors = []
    save = false
    feed_ids.each do |feed_id|
      feed = Feed.find_by_identifier(feed_id)
      unless feed
        cant_find_feed(feed_id)
        return
      end
      unless can_write(feed)
        errors.push("Can't read feed: '#{feed.name}'")
        next
      end
      if session[:type] == 'user'
        track.user_id = session[:id]
      end
      if session[:type] == 'device'
        device = Device.find(session[:id])
        track.user_id = device.user.id
      end
      save = true;
      track.feeds.push(feed)
    end
    track.save
    unless save
      error_denied(["No feeds can be written"])
      return
    end
    if errors && errors.length > 0
      render_error_code(13, errors)
    else
      render json: track
    end
  end

  def get_data
    track = Track.find_by_identifier(params[:identifier])
    unless track
      error_missing_entry(["Track with identifier: '#{params[:identifier]}' can't be found"])
      return
    end
    unless can_read_at_least_one(track.feeds)
      error_denied(["Can't read feed"])
      return
    end
    result = []
    device_name_map = {}
    track.shared_datas.each do |d|
      entry = {}
      entry['timeStamp'] = d.time_stamp
      entry['jsonData'] = d.json_data
      device_id = d.device_id
      unless device_name_map[device_id]
        device_name_map[device_id] = d.device.name
      end
      entry['deviceName'] = device_name_map[d.device_id]
      result << entry
    end
    render json: result
  end

  def index_for_feed
    feed = Feed.find_by_identifier(params[:identifier])
    unless feed
      cant_find_feed(params[:identifier])
      return
    end
    unless can_read(feed)
      error_denied(["Can't read feed"])
      return
    end
    render json: feed.tracks
  end

  def cant_find_feed(identifier)
    error_missing_params(["Can't find feed with identifier: '#{identifier}'"])
  end

  def index_write_for_feed
    feed = Feed.find_by_identifier(params[:identifier])
    unless feed
      cant_find_feed(params[:identifier])
      return
    end
    unless can_read(feed)
      error_denied(["Can't read feed"])
      return
    end
    render json: feed.tracks.find_all_by_user_id(session[:id])
  end

  private
  def track_params
    params.permit(:name)
  end


end
