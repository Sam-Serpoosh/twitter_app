require 'spec_helper'

describe Micropost do

  before do
    @user = Factory(:user)
    @attr = { :content => "lorem ipsum" }
  end

  it "should create a new instance with valid attributes" do
    @user.microposts.create!(@attr)
  end

  describe "user association" do

    before do
      @micropost = @user.microposts.create!(@attr)
    end

    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end

    it "should have the right associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end

  end

end
