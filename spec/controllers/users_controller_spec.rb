require 'spec_helper'

describe UsersController do

  render_views

  describe "GET 'index'" do

    describe "for non signed-in users" do

      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
      end
      
    end

    describe "for signed_in users" do

      before do
        @user = Factory(:user)
        test_sign_in(@user)
        Factory(:user, :email => "user@example.com")
        Factory(:user, :email => "other@yahoo.com")

        30.times do
          Factory(:user, :email => Factory.next(:email))
        end
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end
      
      it "should have an element for each user" do
        get :index
        User.paginate(:page => 1).each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should have pagination" do
        get :index
        response.should have_selector("div", :class => "pagination")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "2")
      end

    end

  end


  describe "GET 'show'" do

    before do
      @user = Factory(:user)
    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user #assigns will pull out the instance variable @user from the controller
    end

    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end

    it "should have the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end

    it "should have the right URL" do
      get :show, :id => @user
      response.should have_selector("td>a", :content => user_path(@user),
                                    :href => user_path(@user))
    end

  end

  describe "GET 'new'" do

    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it "should have the right title" do
      get 'new'
      response.should have_selector("title", :content => "Sign up")
    end

  end

  describe "POST 'create'" do

    describe "failure" do

      before do
        @attr = { :name => "", :email => "", :password => "", 
          :password_confirmation => "" }
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

    end

    describe "success" do

      before do
        @attr = { :name => "New User", :email => "user@example.com", 
          :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to the twitter app!/i
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end

    end

  end

  describe "GET 'edit'" do

    before do 
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end

    it "should have a link to change gravatar" do
      get :edit, :id => @user
      response.should have_selector("a", :href => "http://gravatar.com/emails",
                                    :content => "change")
    end

  end

  describe "PUT 'update'" do

    before do
      @user = Factory(:user)
      @user_id = @user.id
      test_sign_in(@user)
    end


    describe "failure" do

      before do
        @attr = { :name => "", :email => "", :password => "", :password_confirmation => "" }
      end

      it "should redner the edit page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end

    end

    describe "success" do

      before do
        @attr = { :name => "ehsan valizadeh", :email => "user@example.org",
          :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "should change user's attributes" do
        put :update, :id => @user, :user => @attr
        updated_user = assigns(:user)
        @user.reload
        @user.id.should == @user_id
        @user.name.should == "ehsan valizadeh" 
        @user.email.should == "user@example.org" 
        @user.encrypted_password.should == updated_user.encrypted_password
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /Updated/i
      end

    end

  end

  describe "authentication of edit/update actions" do

    before do
      @user = Factory(:user)
    end

    describe "non signed-in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end

      it "should have a message for signing in" do
        get :edit, :id => @user
        flash[:notice].should =~ /sign in/i
      end

    end

    describe "signed-in users" do

      before do
        wrong_user = Factory(:user, :email => "user@example.com")
        test_sign_in(wrong_user)
      end

      it "should require matching userss for edit" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching userss for edit" do
        put :edit, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end

    end

  end

end
