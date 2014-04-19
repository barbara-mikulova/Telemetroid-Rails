class DevicesController < ApplicationController

  protect_from_forgery except: [:create, :edit, :reset_password]
  before_action :require_user_login, :except => [:index_feeds_where_writer]
  before_action :require_login, :only => [:index_feeds_where_writer]

  def create
    device = Device.create(device_params)
    device.user = User.find(session[:id])
    if (device.save)
      render json: device, :only => :password
    else
      render_save_errors(device)
    end
  end

  def reset_password
    device = Device.find_by_identifier(params[:identifier])
    unless device
      error_missing_entry(["Can't find device with identifier '#{params[:identifier]}'"])
      return
    end
    unless device.user_id == session[:id]
      error_denied(['Not your device'])
      return
    end
    device.password = SecureRandom.hex(10)
    device.save
    render json: device, :only => :password
  end

  def edit
    device = Device.find_by_user_id_and_name(session[:id], params[:name])
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
    if user
      remove_identifier = false
      devices = Device.find_all_by_user_id(user.id)
      remove_identifier = true unless (user.id == session[:id])
      response = []
      devices.each do |device|
        response.push(remove_fields(device, remove_identifier))
      end
      render json: response
    else
      error_missing_entry("User with given username couldn't be found")
    end
  end

  def index_permissions
    user = User.find_by_username(params[:username])
    unless user
      error_missing_params(["Can't find user with username '#{params[:username]}'"])
      return
    end
    feed = Feed.find_by_identifier(params[:feed_identifier])
    unless feed
      error_missing_params(["Can't find feed with identifier '#{params[:feed_identifier]}'"])
      return
    end
    unless feed.admins.find_by_user_id(session[:id])
      error_denied(['Only admin can do that'])
      return
    end
    result = []
    user.devices.each do |device|
      write = false
      if feed.writing_devices.find_by_device_id(device.id)
        write = true
      end
      result.push({:name => device.name, :write => write})
    end
    render json: result
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
  def remove_fields(device, remove_identifier)
    hash = JSON.parse(device.to_json)
    if remove_identifier
      hash.delete("identifier")
    end
    hash.delete("password")
    hash.delete("created_at")
    hash.delete("updated_at")
    hash.delete("current_track")
    return hash
  end

  def device_params
    params.permit(:name, :identifier, :comment)
  end

end
