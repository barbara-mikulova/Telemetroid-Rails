class MessagesController < ApplicationController

  protect_from_forgery except: [:insert]

  before_action :require_user_login, only: :insert

  def full_index
    render json: Message.all
  end

  def insert
    render text: 'insert'
  end

  def get_new
    render text: 'get new'
  end
end
