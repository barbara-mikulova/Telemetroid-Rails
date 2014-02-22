class SharedDataController < ApplicationController

  protect_from_forgery :except => [:full_index, :insert]

  def full_index
    data = SharedData.all
    render json: data
  end

  def insert

  end

end
