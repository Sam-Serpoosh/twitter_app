class User < ActiveRecord::Base
  include PasswordEncryption
  include UserAuthentication

  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation

  has_many :microposts, :dependent => :destroy

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, :presence => true,
    :length => { :maximum => 50 }

  validates :email, :presence => true,
    :format => { :with => email_regex },
    :uniqueness => { :case_sensitive => false }

  validates :password, :presence => true,
    :confirmation => true,
    :length => { :within => 6..40 }

  before_save :encryption_of_password

  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    UserAuthentication.authenticate(user, submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  def password_match?(submitted_password)
    self.encrypted_password == encrypt(submitted_password)
  end

  def feed
    Micropost.where("user_id = ?", self.id)
  end

  private

  def encryption_of_password
    self.salt = make_salt if new_record?
    encrypt_password
  end

end
