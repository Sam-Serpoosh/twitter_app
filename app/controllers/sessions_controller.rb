class SessionsController < ApplicationController

  def new
    @title = "Sign in"
  end

  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])

    if user.nil?
      @title = "Sign in"
      flash.now[:error] = "Invalid email/password combination" #cause rendering is not a request we use now so it'll be rendered only once
      render 'new'
    else
      sign_in user
      redirect_back_or(user)
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
