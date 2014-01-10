class DevicesController < ApplicationController
  
  protect_from_forgery except: [:create]
  
  def create
    device = Device.create(device_params)
    device.password = SecureRandom.base64(20)
    if !device.name
      device.name = SecureRandom.base64(10)
    end
    device.user = User.find(session[:id])
    if (device.valid?)
      device.save
      response = {:password => device.password}
      render json: response
    else
      render_save_errors(device)
    end
  end
  
  def index
    render json: Device.all
  end
  
  def render_save_errors(device)
    error_missing_params(device.errors.full_messages)
  end
  
  def device_params
    params.permit(:name, :identifier, :comment, :public)
  end
  
end
