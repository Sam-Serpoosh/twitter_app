require 'spec_helper'

describe "Users" do

  describe "signup" do

    describe "failure" do

      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in "name", :with => ""
          fill_in "email", :with => ""
          fill_in "password", :with => ""
          fill_in "confirmation", :with => ""
          click_button
          response.should render_template('users/new')
          response.should have_selector("div#error_explanation")
        end.should_not change(User, :count)
      end

    end

    describe "success" do

      it "should make a new user" do
        lambda do
          visit signup_path
          fill_in "name", :with => "Example User"
          fill_in "email", :with => "user@example.com"
          fill_in "password", :with => "foobar"
          fill_in "confirmation", :with => "foobar"
          click_button
          response.should have_selector("div.flash.success", :content => "Welcome")
          response.should render_template('users/show')
        end.should change(User, :count).by(1)
      end
    end

  end

  describe "signin" do

    describe "failure" do

      it "should not sign the user in" do
        visit signin_path
        fill_in :email, :with => ""
        fill_in :password, :with => ""
        click_button
        response.should have_selector("div.flash.error", :content => "Invalid")
        response.should render_template('sessions/new')
      end

    end

    describe "success" do

      it "should sign the user in and out" do
        @user = Factory(:user)
        visit signin_path
        fill_in :email, :with => @user.email
        fill_in :password, :with => @user.password
        click_button
        controller.should be_signed_in
        click_link "sign out"
        controller.should_not be_signed_in
      end

    end

  end

end
