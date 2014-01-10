class SessionsController < ApplicationController
  
  protect_from_forgery except: [:login, :logout, :who]
  skip_before_action :require_login, only: [:login, :who]
  
  def login
    user = User.find_by_username(params[:username])
    if (user && user.password == params[:password])
      session[:id] = user.id
      response_ok
    else
      error_denied('wrong username or password')
    end
  end
  
  def who
    if (session[:id])
      render text: User.find(session[:id]).username
    else
      render text: 'nobody'
    end
  end
  
  def logout
    session[:id] = nil
    response_ok
  end
  
end
