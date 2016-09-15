class CallbacksController < ApplicationController
  def twitter
    user = User.find_or_create_from_twitter request.env['omniauth.auth']
    session[:user_id] = user.id
    # render json: request.env['omniauth.auth']
    redirect_to root_path
  end
end
