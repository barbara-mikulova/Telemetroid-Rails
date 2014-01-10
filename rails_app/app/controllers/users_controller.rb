class UsersController < ApplicationController
  protect_from_forgery except: [:create, :change_password, :edit, :show, :find]
  skip_before_action :require_login, only: [:create]
  
  def create
    user = User.create(user_params)
    if (user.valid?)
      user.save
      response_ok
    else
      render_save_errors(user)
    end
  end
  
  def change_password
    user = User.find(session[:id])
    if (user.password == params[:old])
      user.password = params[:new]
      if (user.save)
        response_ok
      else
        render_save_errors(user)
      end
    else
      error_denied("Old password doesn't match")
    end
  end
  
  def edit
    change = false;
    user = User.find(session[:id])
    if (params[:name])
      user.name = params[:name]
      change = true;
    end
    if (params[:note])
      user.note = params[:note]
      change = true;
    end
    if (params[:public_email])
      user.public_email = params[:public_email]
      change = true;
    end
    if (change)
      if (user.save)
        response_ok
      else
        render_save_errors(user)
      end
    else
      response_ok
    end
  end
  
  def show
    user = User.find_by_username(params[:username])
    if (user)
      render json: user
    else
      error_missing_entry("User can't be found")
    end
  end
  
  def find
    if (params[:username] || params[:name] || params[:mail])
      username = params[:username]
      name = params[:name]
      mail = params[:mail]
      if (username)
        users = User.where("username LIKE ?", "%#{username}%")
      end
      if (name)
        if (users)
          users = users.where("name LIKE ?", "%#{name}%")
        else
          users = User.where("name LIKE ?", "%#{name}%")
        end
      end
      if (mail)
        if (users)
          users = users.where({:public_email => true})
          #users = users.where("mail = ?", "#{mail}#")
        else
          users = User.where({:public_email => true})
          #users = User.where("mail = ?", "#{mail}#")
        end
      end
      render json: users
    else
      error_missing_params("Username, Name, Note or E-mail must be provided")
    end
  end
  
  def render_save_errors(user)
    error_missing_params(user.errors.full_messages)
  end
  
  def user_params
    params.permit(:username, :password, :mail, :name, :comment, :public_email)
  end
  
end
