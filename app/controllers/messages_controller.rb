class MessagesController < ApplicationController

  protect_from_forgery except: [:insert]

  before_action :require_device_existence, only: [:insert]
  before_action :require_user_existence, only: [:insert]
  before_action :require_ownership, only: [:insert]

  def full_index
    render json: Message.all
  end

  def insert
    message = Message.new(message_params)
    message.user = @user
    message.device = @device
    if session[:type] == 'user'
      message.read_by_user = false;
    end
    #if session[:type] == 'device'
    #  message.read_by_device = true;
    #end
    if message.save
      response_ok
    else
      render_save_errors(message)
    end
  end

  def get_new
    if session[:type] == 'device'
      show_unread_by_device
      return
    end
    if session[:type] == 'user'
      show_unread_by_user
      return
    end
    render text: 'get new'
  end

  private
  def require_device_existence
    if session[:type] == 'user'
      @device = Device.find_by_identifier(params[:device_identifier])
      unless @device
        error_missing_entry(["Can't find device with identifier: " + params[:device_identifier]])
      end
    else
      @device = Device.find(session[:id])
    end
  end

  def require_user_existence
    if session[:type] == 'user'
      @user = User.find(session[:id])
    else
      @user = User.find_by_username(params[:username])
      unless @user
        error_missing_entry("Can't find user with username: " + params[:username])
      end
    end
  end

  def require_ownership
    unless @device.user == @user
      error_denied(["Can't send orders to devices / users which you do not own / belongs to"])
    end
  end

  def message_params
    params.permit(:message)
  end

  def show_unread_by_device
    device = Device.find(session[:id])
    messages = Message.find_all_by_device_id_and_read_by_device_and_read_by_user(device.id, false, true)
    response = []
    messages.each do |message|
      message.read_by_device = true;
      message.save
      response.push(message.message)
    end
    render json: response
  end

  def show_unread_by_user
    user = User.find(session[:id])
    messages = Message.find_all_by_user_id_and_read_by_user_and_read_by_device(user.id, false, false)
    response = []
    messages.each do |message|
      message.read_by_user = true
      message.save
      response.push(message.message)
    end
    render json: response
  end
end
