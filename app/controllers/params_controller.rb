class ParamsController < ApplicationController
  protect_from_forgery except: :show
  
  def show
    render json: params
  end
  
end
