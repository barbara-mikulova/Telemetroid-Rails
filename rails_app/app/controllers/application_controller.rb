class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :require_login
  
  def require_login
    if (session[:id] == nil)
      error_denied('Please log in')
    end
  end
  
  def require_user_login
    if (session[:type] != 'user')
      error_denied('Please log in')
    end
  end
  
  def remove_user_fields(user)
    hash = JSON.parse(user.to_json)
    hash.delete("password")
    hash.delete("created_at")
    hash.delete("updated_at")
    if !user.public_email
      hash.delete("mail")
    end
    hash.delete("public_email")
    return hash
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
  
  def error_duplicity(messages)
    render_error_code(2, messages)
  end
  
  def render_error_code(code, messages)
    result = ActiveSupport::JSON.encode({code: code, messages: messages})
    render json: result
  end
  
  def response_ok
    render text: ''
  end
  
  def render_save_errors(model)
    error_missing_params(model.errors.full_messages)
  end
  
end
