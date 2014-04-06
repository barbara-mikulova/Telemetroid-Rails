class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :require_login

  def require_login
    if (session[:id] == nil)
      error_denied('Please log in')
    end
  end

  def require_user_login
    if (session[:type] != 'user')
      error_denied('Please log in')
    end
  end

  def remove_user_fields(user)
    hash = JSON.parse(user.to_json)
    hash.delete("password")
    hash.delete("created_at")
    hash.delete("updated_at")
    current_user = User.find(session[:id])
    unless user.public_email || current_user.id == user.id
      hash.delete("mail")
    end
    return hash
  end

  def remove_device_fields(input)
    device = Device.find(input.device_id)
    user = User.find(device.user_id)
    if (device.public)
      name = device.name
    else
      name = "private"
    end
    return {'owner_name' => user.username, 'device_name' => name}
  end

  def remove_feed_fields(feed)
    hash = JSON.parse(feed.to_json)
    hash.delete('created_at')
    hash.delete('updated_at')
    hash.delete('write_key')
    hash.delete('read_key')
    hash.delete('private')
    return hash
  end

  def error_missing_params(messages)
    render_error_code(1, messages)
  end

  def error_missing_entry(messages)
    render_error_code(4, messages)
  end

  def error_denied(messages)
    render_error_code(3, messages);
  end

  def error_duplicity(messages)
    render_error_code(2, messages)
  end

  def render_error_code(code, messages)
    result = ActiveSupport::JSON.encode({code: code, messages: messages})
    render json: result
  end

  def response_ok
    render text: ''
  end

  def render_save_errors(model)
    error_missing_params(model.errors.full_messages)
  end

  def can_read(feed)
    if session[:type] == 'user'
      unless feed.readers.find_by_user_id(session[:id])
        return false
      end
    end
    if session[:type] == 'device'
      unless feed.reading_devices.find_by_device_id(session[:id])
        return false
      end
    end
    return true
  end

  def can_read_at_least_one(feeds)
    if session[:type] == 'user'
      feeds.each do |feed|
        if feed.readers.find_by_user_id(session[:id])
          return true
        end
      end
    end
    if session[:type] == 'device'
      feeds.each do |feed|
        if feed.reading_devices.find_by_device_id(session[:id])
          return true
        end
      end
    end
    return false
  end

  def can_write(feed)
    if session[:type] == 'user'
      unless feed.writers.find_by_user_id(session[:id])
        return false
      end
    end
    if session[:type] == 'device'
      unless feed.writing_devices.find_by_device_id(session[:id])
        return false
      end
    end
    return true
  end

end
