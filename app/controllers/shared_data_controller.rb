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
    @not_written_feed_names = []
    get_writable_ids
    data = []
    tracks = []
    saved = false
    entries = params['entries']
    if entries
      entries.each do |entry|
        feed_ids = entry['feedIdentifiers']
        savable_feeds = get_savable_feeds(feed_ids)
        if savable_feeds.length > 0
          json_data = entry['jsonData']
          share_data = SharedData.new
          share_data.device_id = @device.id
          share_data.json_data = json_data
          savable_feeds.each do |feed|
            share_data.feeds.push(feed)
          end
          track = Track.find_by_identifier(entry['trackIdentifier'])
          if track
            if track.user_id == @device.user_id
              share_data.tracks.push(track)
              track.shared_datas.push(share_data)
              tracks << track
            else
              error_denied(["Only owner can write tracks. You are not owner of '#{track.name}'"])
              return
            end
          else
            error_missing_entry(["Track with identifier: '#{entry['trackIdentifier']}' can't be found"])
            return
          end
          data << share_data
          saved = true
        end
      end
    end
    unless saved
      error_denied(["No feeds were updated"])
      return
    end
    if @not_written_feed_names.length > 0
      @errors.push("These feeds were not updated: " + @not_written_feed_names.to_sentence)
    end
    if @errors.length > 0
      render_error_code(13, @errors)
    else
      response_ok
    end
    SharedData.import data
    Track.import tracks
  end

  private

  def find_device
    @device = Device.find_by_identifier(params[:deviceIdentifier])
  end

  def get_savable_feeds(feed_ids)
    result = []
    feed_ids.each do |feed_id|
      @writable_feeds.each do |writable_feed|
        if writable_feed.identifier == feed_id
          result.push(writable_feed)
        end
      end
    end
    return result
  end

  def get_writable_ids
    @writable_feeds = []
    if session[:type] == 'user'
      writers = Writer.find_all_by_user_id(session[:id])
      writers.each do |writer|
        @writable_feeds.push(writer.feed)
      end
    end
    if session[:type] == 'device'
      writers = WritingDevice.find_all_by_device_id(session[:id])
      writers.each do |writer|
        @writable_feeds.push(writer.feed)
      end
    end
  end

  def push_not_written_feed(feed)
    unless @not_written_feed_names.include?(feed.name)
      @not_written_feed_names.push(feed.name)
    end
  end

end

