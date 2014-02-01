class SharedInfosController < ApplicationController

  protect_from_forgery :except => [:add_one]

  def full_index
    infos = SharedInfo.all
    render json: infos
  end

  def add_one
    render text: 'add data to one feed'
  end

end
