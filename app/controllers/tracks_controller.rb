class TracksController < ApplicationController
  protect_from_forgery :except => [:create]
  before_action :require_user_login

  def full_index
    render json: Track.all
  end

  def create
    track = Track.new(track_params)
    feed = Feed.find_by_identifier(params[:feed_identifier])
    unless feed
      error_missing_entry(["Feed with identifier: '#{params[:feed_identifier]}' can't be found"])
      return
    end
    track.feed = feed
    track.user_id = session[:id]
    if track.save
      feed.tracks.push(track)
      feed.save
      response_ok
    else
      render_save_errors(track)
    end
  end

  def get_data
    track = Track.find_by_identifier(params[:identifier])
    unless track
      error_missing_entry(["Track with identifier: '#{params[:identifier]}' can't be found"])
      return
    end
    unless can_read(track.feed)
      error_denied(["Can't read feed"])
      return
    end
    render json: track.shared_datas
  end

  def index_for_feed
    feed = Feed.find_by_identifier(params[:identifier])
    unless feed
      error_missing_params(["Can't find feed with identifier: '#{params[:identifier]}'"])
      return
    end
    unless can_read(feed)
      error_denied(["Can't read feed"])
      return
    end
    render json: feed.tracks
  end

  def index_write_for_feed
    feed = Feed.find_by_identifier(params[:identifier])
    unless feed
      error_missing_params(["Can't find feed with identifier: '#{params[:identifier]}'"])
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
