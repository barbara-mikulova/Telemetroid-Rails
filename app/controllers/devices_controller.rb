class DevicesController < ApplicationController
  
  protect_from_forgery except: [:create, :edit]
  before_action :require_user_login
  
  def create
    device = Device.create(device_params)
    device.user = User.find(session[:id])
    if (device.save)
      response = {:password => device.password}
      render json: response
    else
      render_save_errors(device)
    end
  end
  
  def edit
    device = Device.find_by_user_id_and_name(session[:id], params[:device_name])
    if (device)
      change = false
      if (params[:new_name])
        device.name = params[:new_name]
        change = true
      end
      if (params[:comment])
        device.comment = params[:comment]
        change = true
      end
      if (params[:public])
        device.public = params[:public]
        change = true
      end
      if (change)
        if (device.save)
          response_ok
        else
          render_save_errors(device)
        end
      else
        response_ok
      end
    else
      error_missing_entry("Device with given name couldn't be found")
    end
  end
  
  def full_index
    render json: Device.all
  end
  
  def index
    user = User.find_by_username(params[:username])
    if (user)
      if (user.id == session[:id])
        devices = Device.find_all_by_user_id(user.id)  
      else
        devices = Device.find_all_by_user_id_and_public(user.id, true)
      end
      response = []
      devices.each do |device|
        response.push(remove_fields(device))
      end
      render json: response
    else
      error_missing_entry("User with given username couldn't be found")
    end
  end

  def index_feeds_where_reader
    device = Device.find_by_identifier(params[:identifier])
    if device
      readers = ReadingDevice.find_all_by_device_id(device.id)
      result = []
      readers.each do |reader|
        result.push(remove_feed_fields(reader.feed))
      end
      render json: result
    else
      error_missing_entry(["Device can't be found"])
    end
  end

  def index_feeds_where_writer
    device = Device.find_by_identifier(params[:identifier])
    if device
      writers = WritingDevice.find_all_by_device_id(device.id)
      result = []
      writers.each do |writer|
        result.push(remove_feed_fields(writer.feed))
      end
      render json: result
    else
      error_missing_entry(["Device can't be found"])
    end
  end

  private
  def remove_fields(device)
    hash = JSON.parse(device.to_json)
    hash.delete("identifier")
    hash.delete("password")
    hash.delete("created_at")
    hash.delete("updated_at")
    hash.delete("public")
    hash.delete("current_track")
    return hash
  end
  
  def device_params
    params.permit(:name, :identifier, :comment, :public)
  end
  
end
