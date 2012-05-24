class PagesController < ApplicationController

  def home
    @micropost = Micropost.new if signed_in?
    @title = "Home"
  end

  def contact
    @title = "Contact"
  end

  def about
    @title = "About"
  end

  def help
    @title = "Help"
  end

end
