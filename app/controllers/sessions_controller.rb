require "octokit"

class SessionsController < ApplicationController
  def new
    redirect_to "/auth/github"
  end

  def create
    user = user_from_omniauth
    if user.present?
      flash[:success] = "You are signed in"
      session[:user_id] = user.id
    else
      flash[:danger] = "You could not be authenticated"
    end
    destination = session[:return_to] || responses_path
    redirect_to destination
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "You have been signed out"
    redirect_to new_session_path
  end

  private

  def user_from_omniauth
    auth = request.env["omniauth.auth"]
    User.find_or_create_by(github_id: auth.uid) do |user|
      user.login = auth.info.nickname
      user.email = auth.info.email
      user.name = auth.info.name
    end
  end
end
