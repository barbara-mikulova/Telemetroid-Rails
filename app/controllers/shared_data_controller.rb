class SharedDataController < ApplicationController

  protect_from_forgery :except => [:full_index, :insert]
  WRONG_TRACK_TYPE = -2

  def full_index
    data = SharedData.all
    render json: data
  end

  def insert
    find_device
    unless @device
      error_missing_entry(["Device with identifier #{params[:deviceIdentifier]} can't be found"])
      return
    end
    @errors = []
    data = []
    @not_written_feed_names = []
    saved = false
    entries = params['entries']
    puts '*******************************' + entries.length.to_s
    if entries
      entries.each do |entry|
        feed_ids = entry['feedIdentifiers']
        savable_feeds = get_savable_feeds(feed_ids)
        if savable_feeds.length > 0
          json_data = entry['jsonData']
          track_type = entry['trackType']
          share_data = SharedData.new
          share_data.device = @device
          share_data.json_data = json_data
          track_id = get_track_type(track_type)
          if track_id == -2
            error_missing_params(["Wrong track type: #{track_type}"])
            return
          else
            share_data.track_id = track_id
          end
          savable_feeds.each do |feed|
            share_data.feeds.push(feed)
          end
          data << share_data
          saved = true
          @device.save
        end
      end
    end
    unless saved
      error_denied(["No feeds were updated"])
      return
    end
    SharedData.import data
    if @not_written_feed_names.length > 0
      @errors.push("These feeds were not updated: " + @not_written_feed_names.to_sentence)
    end
    if @errors.length > 0
      render_error_code(13, @errors)
    else
      response_ok
    end
  end

  private

  def find_device
    @device = Device.find_by_identifier(params[:deviceIdentifier])
  end

  def get_track_type(type)
    if type == 'new'
      return @device.current_track + 1;
    end
    if type == 'append'
      return @device.current_track
    end
    if type == 'standalone'
      return -1
    end
    return WRONG_TRACK_TYPE
  end

  def get_savable_feeds(feed_ids)
    result = []
    feed_ids.each do |feed_id|
      feed = Feed.find_by_identifier(feed_id)
      if feed
        if session[:type] == 'user'
          if Writer.find_by_feed_id_and_user_id(feed.id, session[:id])
            result.push(feed)
          else
            push_not_written_feed(feed)
          end
        elsif session[:type] == 'device'
          if WritingDevice.find_by_feed_id_and_user_id(feed.id, session[:id])
            result.push(feed)
          else
            push_not_written_feed(feed)
          end
        end
      else
        @errors.push("Can't find feed with id #{feed_id}")
      end
    end
    return result
  end

  def push_not_written_feed(feed)
    unless @not_written_feed_names.include?(feed.name)
      @not_written_feed_names.push(feed.name)
    end
  end

end

