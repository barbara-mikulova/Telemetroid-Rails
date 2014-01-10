class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :require_login
  
  def require_login
    if (session[:id] == nil)
      error_denied([session[:id].to_s, 'Please log in'])
    end
  end
  
  def error_missing_params(messages)
    render_error_code(1, messages)
  end
  
  def error_missing_entry(messages)
    render_error_code(4, messages)
  end
  
  def error_denied(messages)
    render_error_code(3, messages);
  end
  
  def render_error_code(code, messages)
    result = ActiveSupport::JSON.encode({code: code, messages: messages})
    render json: result
  end
  
  def response_ok
    render text: ''
  end
  
end
