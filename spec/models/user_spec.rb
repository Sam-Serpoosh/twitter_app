require 'spec_helper'

describe User do

  before do
    @attr = { :name => "user", :email => "user@example.com", 
      :password => "foobar", :password_confirmation => "foobar" }
  end

  it "should create instance given a valid attribute" do 
    User.create!(@attr)
  end  

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should require an email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should reject names that are too long" do
    too_long_name_user = User.new(@attr.merge(:name => "a" * 51))
    too_long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each  do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email] .upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "passwords" do 

    before do
      @user = User.new(@attr)
    end

    it "should have a password attribute" do
      @user.should respond_to(:password)
    end

    it "should have a password confirmation" do
      @user.should respond_to(:password_confirmation)
    end

    describe "password validaton" do 

      it "should require a password" do
        User.new(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
      end

      it "should require a matching password confirmation" do
        User.new(@attr.merge(:password_confirmation => "invalid")).should_not be_valid
      end

      it "should reject short passwords" do
        short_password = "a" * 5
        hash = @attr.merge(:password => short_password, :password_confirmation => short_password)
        User.new(hash).should_not be_valid
      end

      it "should reject long passwords" do
        long_password = "a" * 41
        hash = @attr.merge(:password => long_password, :password_confirmation => long_password)
        User.new(hash).should_not be_valid
      end

      describe "password encryption" do

        before do
          @user = User.create!(@attr)
        end

        it "should have an encrypted password attribute" do
          @user.should respond_to(:encrypted_password)
        end

        it "should set the encrypted password attribute" do
          @user.encrypted_password.should_not be_blank
        end

        it "should have a sult" do
          @user.should respond_to(:salt)
        end

        describe "has_password? method" do 

          it "should exist" do
            @user.should respond_to(:password_match?)
          end

          it "should return true if the passwords match" do
            @user.password_match?(@attr[:password]).should be_true
          end

          it "should return false if the passwords don't match" do
            @user.password_match?("invalid").should be_false
          end

        end

        describe "authenticate method" do

          it "should respond to" do
            User.should respond_to(:authenticate)
          end

          it "should return nil on email/password mismatch" do
            User.authenticate(@user[:email], "wrongpass").should be_nil
          end

          it "should return nil on email address with no user" do
            User.authenticate("bar@foo.com", @attr[:password]).should be_nil
          end

          it "should return the user on email/password match" do
            User.authenticate(@attr[:email], @attr[:password]).should == @user
          end

        end

      end

    end 

  end 

end
