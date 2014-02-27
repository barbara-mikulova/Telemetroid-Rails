class MessagesController < ApplicationController

  protect_from_forgery except: [:insert]

  before_action :require_device_existence, only: :insert
  before_action :require_user_existence, only: :insert
  before_action :require_authenticity, only: :insert
  before_action :require_ownership, only: :insert

  def full_index
    render json: Message.all
  end

  def insert
    message = Message.new(message_params)
    message.user = @user
    message.device = @device
    if message.save
      response_ok
    else
      render_save_errors(message)
    end
  end

  def get_new
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

  def require_authenticity
    if session[:type] == 'user'
      unless session[:id] == @user.id
        error_denied(['Not your username'])
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
end
