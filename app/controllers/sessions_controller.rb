class SessionsController < ApplicationController
  
  protect_from_forgery except: [:login, :logout, :who, :device_login]
  skip_before_action :require_login, only: [:login, :who, :device_login]
  
  def login
    user = User.find_by_username(params[:username])
    if (user && user.password == params[:password])
      session[:id] = user.id
      session[:type] = 'user'
      response_ok
    else
      error_denied(['wrong username or password'])
    end
  end
  
  def device_login
    device = Device.find_by_identifier(params[:identifier])
    if (device && device.password == params[:password])
      session[:id] = device.id
      session[:type] = 'device'
      response_ok
    else
      error_denied(['wrong identifier or password'])
    end
  end
  
  def who
    if (session[:id])
      if (session[:type] == 'user')
        render text: 'user ' + User.find(session[:id]).username
      end
      if (session[:type] == 'device')
        render text: 'device ' + Device.find(session[:id]).name
      end
    else
      render text: 'nobody'
    end
  end
  
  def logout
    session[:id] = nil
    session[:type] = nil
    response_ok
  end
  
end
