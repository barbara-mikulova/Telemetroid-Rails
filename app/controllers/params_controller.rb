class ParamsController < ApplicationController
  protect_from_forgery except: :show
  
  def show
    render text: params
  end
  
end
