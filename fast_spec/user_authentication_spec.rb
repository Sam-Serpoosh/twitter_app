require File.expand_path(File.dirname(__FILE__) + '/fast_spec_helper')

describe "User Authentication" do

  it "should return nil when user is nil" do
    UserAuthentication.authenticate(nil, "any password").should be_nil
  end

  it "should return nil when password is wrong" do
    user = stub(:password_match? => false)
    UserAuthentication.authenticate(user, "wrong_password").should be_nil
  end

  it "should return the user when password match" do
    user = double()
    user.stub(:password_match?).with("correct_password") { true }
    UserAuthentication.authenticate(user, "correct_password").should == user 
  end

end
