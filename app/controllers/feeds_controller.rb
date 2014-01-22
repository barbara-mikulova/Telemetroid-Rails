class FeedsController < ApplicationController
  
  protect_from_forgery except: [:create, :add_admin, :remove_admin, :add_user_write, :remove_user_write,
                                :add_user_read, :remove_user_read]
  before_action :require_user_login
  before_action :require_admin, :except => [:create, :index_admins, :index_users_writers,
                                            :index_users_readers, :full_index]
  
  def require_admin
    feed = Feed.find_by_identifier(params[:identifier])
    if (feed)
      admin = Admin.find_by_user_id_and_feed_id(session[:id], feed.id)
      if (admin)
        return true
      end
      error_denied("You must be admin to do that")
    end
  end
  
  def create
    user = User.find(session[:id])
    feed = Feed.create(feed_params)
    admin = Admin.new
    admin.user = user
    feed.admins.push(admin)
    if (feed.save)
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
    if (feed)
      admins = feed.admins
      response = []
      admins.each do |admin|
        response.push(remove_user_fields(admin.user))
      end
      render json: response
    else
      error_missing_entry("Can't find feed")
    end
  end
  
  def index_users_writers
    feed = Feed.find_by_identifier(params[:identifier])
    if (feed)
      writers = feed.writers
      print_user_array(writers)
    else
      error_missing_entry("Can't find feed")
    end
  end
  
  def index_users_readers
    feed = Feed.find_by_identifier(params[:identifier])
    if (feed)
      readers = feed.readers
      print_user_array(readers)
    else
      error_missing_entry("Can't find feed")
    end
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
    if (user)
      feed = Feed.find_by_identifier(params[:identifier])
      if (feed)
        admin = Admin.find_by_user_id_and_feed_id(user.id, feed.id)
        if (admin)
          error_duplicity(user.username + " is already admin")
        else
          admin = Admin.new
          admin.user = user
          feed.admins.push(admin)
          feed.save
          response_ok
        end
      else
        error_missing_entry("Can't find feed")
      end
    else
      error_missing_entry("Can't find user " + params[:username])
    end
  end
  
  def remove_admin
    user = User.find_by_username(params[:username])
    if (user)
      feed = Feed.find_by_identifier(params[:identifier])
      if (feed)
        if (feed.admins.length < 2)
          error_denied("At least one admin must be always present")
        else
          admin = Admin.find_by_user_id_and_feed_id(user.id, feed.id)
          if (admin)
            feed.admins.delete(admin)
            admin.delete
            feed.save
            response_ok
          else
            error_missing_params("User " + user.username + " is not admin")
          end
        end
      else
        error_missing_entry("Can't find feed")
      end
    else
      error_missing_entry("Can't find user " + params[:username])
    end
  end
  
  def add_user_write
    user = User.find_by_username(params[:username])
    if (user)
      feed = Feed.find_by_identifier(params[:identifier])
      if (feed)
        writer = Writer.find_by_user_id_and_feed_id(user.id, feed.id)
        if (writer)
          error_duplicity(user.username + " can write to feed already")
        else
          writer = Writer.new
          writer.user = user
          feed.writers.push(writer)
          feed.save
          response_ok
        end
      else
        error_missing_entry("Can't find feed")
      end
    else
      error_missing_entry("Can't find user " + params[:username])
    end
  end
  
  def remove_user_write
    user = User.find_by_username(params[:username])
    if (user)
      feed = Feed.find_by_identifier(params[:identifier])
      if (feed)
        writer = Writer.find_by_user_id_and_feed_id(user.id, feed.id)
        if (writer)
          feed.writers.delete(writer)
          writer.delete
          feed.save
          response_ok
        else
          error_missing_params("User " + user.username + " can't write to this feed")
        end
      else
        error_missing_entry("Can't find feed")
      end
    else
      error_missing_entry("Can't find user " + params[:username])
    end
  end
  
  def add_user_read
    user = User.find_by_username(params[:username])
    if (user)
      feed = Feed.find_by_identifier(params[:identifier])
      if (feed)
        reader = Reader.find_by_user_id_and_feed_id(user.id, feed.id)
        if (reader)
          error_duplicity(user.username + " can read feed already")
        else
          reader = Reader.new
          reader.user = user
          feed.readers.push(reader)
          feed.save
          response_ok
        end
      else
        error_missing_entry("Can't find feed")
      end
    else
      error_missing_entry("Can't find user " + params[:username])
    end
  end
  
  def remove_user_read
    user = User.find_by_username(params[:username])
    if (user)
      feed = Feed.find_by_identifier(params[:identifier])
      if (feed)
        reader = Reader.find_by_user_id_and_feed_id(user.id, feed.id)
        if (reader)
          feed.readers.delete(reader)
          reader.delete
          feed.save
          response_ok
        else
          error_missing_params("User " + user.username + " can't read this feed")
        end
      else
        error_missing_entry("Can't find feed")
      end
    else
      error_missing_entry("Can't find user " + params[:username])
    end
  end
  
  def feed_params
    params.permit(:name, :comment, :public)
  end
  
end
