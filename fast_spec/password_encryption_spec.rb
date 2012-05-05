require File.expand_path(File.dirname(__FILE__) + '/fast_spec_helper')

class StubUser
  include PasswordEncryption

  attr_accessor :encrypted_password

end


describe "Password Encryption" do

  it "should set the encrypted password based on password" do
    user = StubUser.new
    user.stub(:password => "foobar")
    user.encrypt_password 
    user.encrypted_password.should == "foobar"
  end

end
