module RequiresAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication!
  end

  def require_authentication!
    unless current_user.present?
      redirect_to new_session_path
    end
  end

  def current_user
    if session[:user_id].present?
      user = User.find_by(id: session[:user_id])
      if user.present?
        Current.user = user
      else
        session[:user_id] = nil
        Current.user = nil
      end
    end
  end
end
