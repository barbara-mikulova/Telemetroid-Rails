class FeedsController < ApplicationController
  
  protect_from_forgery except: [:create, :add_admin, :remove_admin, :add_user_write,
                                :remove_user_write, :add_user_read, :remove_user_read,
                                :add_writing_device, :remove_writing_device,
                                :add_reading_device, :remove_reading_device]
  
  before_action :require_user_login
  before_action :require_admin, :except => [:create, :index_admins, :index_users_writers,
                                            :index_users_readers, :index_writing_devices,
                                            :index_reading_devices, :full_index, :show_read_key,
                                            :show_write_key]

  before_action :require_read_access, :only => :show_read_key
  before_action :require_write_access, :only => :show_write_key
  before_action :require_feed_existence, :only => [:index_admins, :index_users_readers,
                                                  :index_users_writers, :index_reading_devices,
                                                  :index_writing_devices, :add_admin, :remove_admin,
                                                  :add_user_read, :remove_user_read, :add_user_write,
                                                  :remove_user_write, :add_reading_device,
                                                  :remove_reading_device, :add_writing_device,
                                                  :remove_writing_device, :require_admin,
                                                  :require_read_access, :require_write_access]


  def create
    user = User.find(session[:id])
    feed = Feed.create(feed_params)
    admin = Admin.new
    admin.user = user
    feed.admins.push(admin)
    if feed.save
      response = {:identifier => feed.identifier}
      render json: response
    else
      render_save_errors(feed)
    end
  end

  def full_index
    render json: Feed.all
  end

  def index_admins
    feed = Feed.find_by_identifier(params[:identifier])
    admins = feed.admins
    response = []
    admins.each do |admin|
      response.push(remove_user_fields(admin.user))
    end
    render json: response
  end

  def show_write_key
    feed = Feed.find_by_identifier(params[:identifier])
    response = {:write_key => feed.write_key}
    render json: response
  end

  def show_read_key
    feed = Feed.find_by_identifier(params[:identifier])
    response = {:read_key => feed.read_key}
    render json: response
  end

  def index_users_writers
    feed = Feed.find_by_identifier(params[:identifier])
    writers = feed.writers
    print_user_array(writers)
  end

  def index_users_readers
    feed = Feed.find_by_identifier(params[:identifier])
    readers = feed.readers
    print_user_array(readers)
  end

  def index_writing_devices
    feed = Feed.find_by_identifier(params[:identifier])
    writing_devices = feed.writing_devices
    print_device_array(writing_devices)
  end

  def index_reading_devices
    feed = Feed.find_by_identifier(params[:identifier])
    reading_devices = feed.reading_devices
    print_device_array(reading_devices)
  end

  def print_device_array(devices)
    response = []
    devices.each do |device|
      response.push(remove_device_fields(device))
    end
    render json: response
  end

  def print_user_array(entries)
    response = []
    entries.each do |entry|
      response.push(remove_user_fields(entry.user))
    end
    render json: response
  end

  def add_admin
    user = User.find_by_username(params[:username])
    if user
      feed = Feed.find_by_identifier(params[:identifier])
      admin = Admin.find_by_user_id_and_feed_id(user.id, feed.id)
      if admin
        error_duplicity([user.username + " is already admin"])
      else
        admin = Admin.new
        admin.user = user
        feed.admins.push(admin)
        feed.save
        response_ok
      end
    else
      cant_find_user
    end
  end

  def remove_admin
    user = User.find_by_username(params[:username])
    if user
      feed = Feed.find_by_identifier(params[:identifier])
      if feed.admins.length < 2
        error_denied(["At least one admin must be always present"])
      else
        admin = Admin.find_by_user_id_and_feed_id(user.id, feed.id)
        if admin
          feed.admins.delete(admin)
          admin.delete
          feed.save
          response_ok
        else
          error_missing_params(["User " + user.username + " is not admin"])
        end
      end
    else
      cant_find_user
    end
  end

  def add_user_write
    user = User.find_by_username(params[:username])
    if user
      feed = Feed.find_by_identifier(params[:identifier])
      writer = Writer.find_by_user_id_and_feed_id(user.id, feed.id)
      if writer
        error_duplicity([user.username + " can write to feed already"])
      else
        writer = Writer.new
        writer.user = user
        feed.writers.push(writer)
        feed.save
        response_ok
      end
    else
      cant_find_user
    end
  end

  def remove_user_write
    user = User.find_by_username(params[:username])
    if user
      feed = Feed.find_by_identifier(params[:identifier])
      writer = Writer.find_by_user_id_and_feed_id(user.id, feed.id)
      if writer
        feed.writers.delete(writer)
        writer.delete
        feed.save
        response_ok
      else
        error_missing_params(["User " + user.username + " can't write to this feed"])
      end
    else
      cant_find_user
    end
  end

  def add_user_read
    user = User.find_by_username(params[:username])
    if user
      feed = Feed.find_by_identifier(params[:identifier])
      reader = Reader.find_by_user_id_and_feed_id(user.id, feed.id)
      if reader
        error_duplicity([user.username + " can read feed already"])
      else
        reader = Reader.new
        reader.user = user
        feed.readers.push(reader)
        feed.save
        response_ok
      end
    else
      cant_find_user
    end
  end

  def remove_user_read
    user = User.find_by_username(params[:username])
    if user
      feed = Feed.find_by_identifier(params[:identifier])
      reader = Reader.find_by_user_id_and_feed_id(user.id, feed.id)
      if reader
        feed.readers.delete(reader)
        reader.delete
        feed.save
        response_ok
      else
        error_missing_params(["User " + user.username + " can't read this feed"])
      end
    else
      error_missing_entry(["Can't find user " + params[:username]])
    end
  end

  def add_writing_device
    user = User.find_by_username(params[:username])
    if user
      device = Device.find_by_user_id_and_name(user.id, params[:device_name])
      if device
        feed = Feed.find_by_identifier(params[:identifier])
        writer = WritingDevice.find_by_device_id_and_feed_id(device.id, feed.id)
        if writer
          error_duplicity(["Device " + device.name + " of user " + user.username + " can write to feed already"])
        else
          writer = WritingDevice.new
          writer.device = device
          feed.writing_devices.push(writer)
          feed.save
          response_ok
        end
      else
        error_missing_entry(["Can't find device " + params[:device_name] + " of user " + user.username])
      end
    else
      cant_find_user
    end
  end

  def remove_writing_device
    user = User.find_by_username(params[:username])
    if user
      device = Device.find_by_user_id_and_name(user.id, params[:device_name])
      if device
        feed = Feed.find_by_identifier(params[:identifier])
        writer = WritingDevice.find_by_device_id_and_feed_id(device.id, feed.id)
        if writer
          feed.writing_devices.delete(writer)
          writer.delete
          feed.save
          response_ok
        else
          error_missing_params(["Device " + device.name + " of user " + user.username + " can't write to this feed"])
        end
      else
        error_missing_entry(["Can't find device " + params[:device_name] + " of user " + user.username])
      end
    else
      cant_find_user
    end
  end

  def add_reading_device
    user = User.find_by_username(params[:username])
    if user
      device = Device.find_by_user_id_and_name(user.id, params[:device_name])
      if device
        feed = Feed.find_by_identifier(params[:identifier])
        reader = ReadingDevice.find_by_device_id_and_feed_id(device.id, feed.id)
        if reader
          error_duplicity(["Device " + device.name + " of user " + user.username + " can read feed already"])
        else
          reader = ReadingDevice.new
          reader.device = device
          feed.reading_devices.push(reader)
          feed.save
          response_ok
        end
      else
        error_missing_entry(["Can't find device " + params[:device_name] + " of user " + user.username])
      end
    else
      cant_find_user
    end
  end

  def remove_reading_device
    user = User.find_by_username(params[:username])
    if user
      device = Device.find_by_user_id_and_name(user.id, params[:device_name])
      if device
        feed = Feed.find_by_identifier(params[:identifier])
        reader = ReadingDevice.find_by_device_id_and_feed_id(device.id, feed.id)
        if reader
          feed.reading_devices.delete(reader)
          reader.delete
          feed.save
          response_ok
        else
          error_missing_params(["Device " + device.name + " of user " + user.username + " can't read this feed"])
        end
      else
        error_missing_entry(["Can't find device " + params[:device_name] + " of user " + user.username])
      end
    else
      cant_find_user
    end
  end

  def require_feed_existence
    feed = Feed.find_by_identifier(params[:identifier])
    if not feed
      cant_find_feed
    end
  end

  def require_admin
    feed = Feed.find_by_identifier(params[:identifier])
    if feed
      admin = Admin.find_by_user_id_and_feed_id(session[:id], feed.id)
      if admin
        return true
      end
      error_denied(['You must be admin to do that'])
    end
  end

  def require_read_access
    feed = Feed.find_by_identifier(params[:identifier])
    user = User.find(session[:id])
    if Reader.find_by_feed_id_and_user_id(feed.id, user.id) == nil
      error_denied(["Can't show read key to someone who can't read that feed"])
      return false
    end
    return true
  end

  def require_write_access
    feed = Feed.find_by_identifier(params[:identifier])
    user = User.find(session[:id])
    if Writer.find_by_feed_id_and_user_id(feed.id, user.id) == nil
      error_denied(["Can't show write key to someone who can't write to that feed"])
      return false
    end
    return true
  end

  private
  def cant_find_user
    error_missing_entry(["Can't find user " + params[:username]])
  end

  def cant_find_feed
    error_missing_entry(["Can't find feed"])
  end

  def feed_params
    params.permit(:name, :comment, :public)
  end


end
