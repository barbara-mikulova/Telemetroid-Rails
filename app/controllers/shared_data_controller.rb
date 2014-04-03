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
    get_writable_ids
    unless @writable_feeds.length > 0
      error_denied(['No feeds can be written'])
      return
    end
    @errors = []
    save_data = []
    time_stamp = params[:timeStamp]
    entries = params[:entries]
    entries.each do |entry|
      feeds_identifiers = entry['feedsIdentifiers']
      writable_feeds = []
      feeds_identifiers.each do |feed_id|
        feed = Feed.find_by_identifier(feed_id)
        if @writable_feeds.include?(feed_id)
          writable_feeds << feed
        else
          @errors << "Can't write feed: '#{feed.name}'"
        end
      end
      unless writable_feeds.length > 0
        next
      end
      track = Track.find_by_identifier(entry['trackIdentifier'])
      unless track
        error_missing_params(["Can't find track with identifier: '#{entry['trackIdentifier']}'"])
        return
      end
      unless track.user_id == @device.user_id
        @errors << "Only owner can write tracks. Track '#{track.name}' can't be written"
      end
      writable_feeds.each do |feed|
        unless feed.tracks.where('track_id = ?', track.id).length > 0
          error_missing_entry(["Feed '#{feed.name}' doesn't contain track '#{track.name}'"])
          return
        end
      end
      data = entry['data']
      data.each do |d|
        sharedData = SharedData.new
        sharedData.device_id = @device.id
        sharedData.json_data = d
        sharedData.track_id = track.id
        writable_feeds.each do |feed|
          sharedData.feeds.push(feed)
        end
        save_data << sharedData
      end
    end
    SharedData.import save_data
    if @errors.length > 0
      error_missing_params(@errors)
    else
      response_ok
    end
  end

  private

  def find_device
    @device = Device.find_by_identifier(params[:deviceIdentifier])
  end

  def get_savable_feeds(feed_ids)
    result = []
    feed_ids.each do |feed_id|
      @writable_feeds.each do |writable_feed|
        if writable_feed == feed_id
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
        @writable_feeds.push(writer.feed.identifier)
      end
    end
    if session[:type] == 'device'
      writers = WritingDevice.find_all_by_device_id(session[:id])
      writers.each do |writer|
        @writable_feeds.push(writer.feed.identifier)
      end
    end
  end

  def push_not_written_feed(feed)
    unless @not_written_feed_names.include?(feed.name)
      @not_written_feed_names.push(feed.name)
    end
  end

end

