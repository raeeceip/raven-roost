# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    user = User.from_google_auth(auth)
    
    if user.persisted?
      session[:user_id] = user.id
      redirect_to session.delete(:return_to) || root_path, notice: 'Signed in successfully!'
    else
      redirect_to root_path, alert: 'Authentication failed.'
    end
  end
  
  def destroy
    session.clear
    redirect_to root_path, notice: 'Signed out successfully!'
  end
  
  def failure
    redirect_to root_path, alert: 'Authentication failed.'
  end
end
