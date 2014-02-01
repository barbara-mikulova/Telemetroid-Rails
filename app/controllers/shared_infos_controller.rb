class SharedInfosController < ApplicationController

  def full_index
    infos = SharedInfo.all
    render json: infos
  end

end
