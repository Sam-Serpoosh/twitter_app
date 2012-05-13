class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @title = @user.name
  end

  def new
    @user = User.new
    @title = "Sign up"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Welcome to the Twitter App!" #flash remains only for one request and redirect is a request
      sign_in(@user)
      redirect_to user_path(@user)
    else
      @title = "Sign up"
      render 'new'
    end
  end

end
