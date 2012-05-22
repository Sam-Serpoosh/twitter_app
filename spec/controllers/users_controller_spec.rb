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

      it "should not have delete links for non-admins" do
        other_user = User.all.second
        get :index
        response.should_not have_selector("a", :href => user_path(other_user.id),
                                           :content => "delete")
      end

      it "should have delete links for admins" do
        @user.toggle!(:admin)
        other_user = User.all.second
        get :index
        response.should have_selector("a", :href => user_path(other_user.id),
                                           :content => "delete")
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

    it "should show the user's microposts" do
      mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
      mp2 = Factory(:micropost, :user => @user, :content => "Baz quux")
      get :show, :id => @user
      response.should have_selector("span.content", :content => mp1.content)
      response.should have_selector("span.content", :content => mp2.content)
    end
    
    it "should paginate microposts" do
      31.times { Factory(:micropost, :user => @user, :content => "Foo bar") }
      get :show, :id => @user
      response.should have_selector("div.pagination")
    end

    it "should show the number of user's microposts" do
      2.times { Factory(:micropost, :user => @user, :content => "Foo bar") }
      get :show, :id => @user
      response.should have_selector("td.sidebar", :content => @user.microposts.count.to_s)
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

  describe "DELETE 'destory'" do
    
    before do
      @user = Factory(:user)
    end

    describe "non signed-in user" do

      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end

    end

    describe "non-admin user" do

      it "should protect the action" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end

    end

    describe "admin user" do

      before do
        @admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(@admin)
      end

      it "should delete the user" do
        lambda do
          delete :destroy, :id => @user
          flash[:success].should =~ /destroyed/i
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path) 
      end

      it "should not be able to delete itself" do
        lambda do
          delete :destroy, :id => @admin
          response.should redirect_to(root_path)
        end.should_not change(User, :count)
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
