class UsersController < ApplicationController
  protect_from_forgery except: [:create, :change_password, :edit, :show, :find]
  before_action :require_user_login
  skip_before_action :require_login, only: [:create]
  skip_before_action :require_user_login, only: [:create]

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
      error_denied(["Old password doesn't match"])
    end
  end

  def full_index
    render json: User.all
  end

  def index
    render json: User.all, :only => :username
  end

  def edit
    change = false;
    user = User.find(session[:id])
    if params[:name]
      user.name = params[:name]
      change = true;
    end
    if params[:comment]
      user.comment = params[:comment]
      change = true;
    end
    if params[:public_email]
      user.public_email = params[:public_email]
      change = true;
    end
    if change
      if user.save
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
      response = remove_user_fields(user)
      render json: response
    else
      error_missing_entry(["User can't be found"])
    end
  end

  def find
    if (params[:username] || params[:name] || params[:mail])
      username = params[:username]
      name = params[:name]
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
      response = []
      users.each do |user|
        response.push(remove_user_fields(user))
      end
      render json: response
    else
      error_missing_params(["Username or Name must be provided"])
    end
  end

  def index_feeds_where_admin
    user = User.find_by_username(params[:username])
    if user
      admins = Admin.find_all_by_user_id(user.id)
      result = []
      admins.each do |admin|
        result.push(remove_feed_fields(admin.feed))
      end
      render json: result
    else
      error_missing_entry(['User ' + params[:username] + "can't be found"])
    end
  end

  def index_feeds_where_reader
    user = User.find_by_username(params[:username])
    if user
      readers = Reader.find_all_by_user_id(user.id)
      result = []
      readers.each do |reader|
        result.push(remove_feed_fields(reader.feed))
      end
      render json: result
    else
      error_missing_entry(['User ' + params[:username] + "can't be found"])
    end
  end

  def index_feeds_where_writer
    user = User.find_by_username(params[:username])
    if user
      writers = Writer.find_all_by_user_id(user.id)
      result = []
      writers.each do |writer|
        result.push(remove_feed_fields(writer.feed))
      end
      render json: result
    else
      error_missing_entry(['User ' + params[:username] + "can't be found"])
    end
  end

  private
  def user_params
    params.permit(:username, :password, :mail, :name, :comment, :public_email)
  end

end
