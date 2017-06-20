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
    @current_user ||=
      if session[:current_user_id].present?
        user = User.find_by(id: session[:current_user_id])
        if user.present?
          user
        else
          session[:current_user_id] = nil
          nil
        end
      end
  end
end
