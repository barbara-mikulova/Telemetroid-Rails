class SharedInfosController < ApplicationController

  protect_from_forgery except: [:add_one]

  before_action :require_feed_existence, :require_device_existence, except: [:full_index]

  def full_index
    infos = SharedInfo.all
    render json: infos
  end

  def add_one
    create_shared_info
    if (@info.save)
      render json: @info
    else
      render_save_errors(@info)
      return
    end
  end

  def create_shared_info
    @info = SharedInfo.create
    @info.device = @device
    @info.feed = @feed
    @info.json = params[:json]
  end

  private
  def require_device_existence
    @device = Device.find_by_identifier(params[:device_identif])
    if not @device
      error_missing_entry(["Can't find device"])
      return
    end
  end

  def require_feed_existence
    @feed = Feed.find_by_identifier(params[:identifier])
    if not @feed
      error_missing_entry(["Can't find feed"])
      return
    end
  end

end
