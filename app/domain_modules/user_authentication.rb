module UserAuthentication

  def self.authenticate(user, password) 
    return nil if user.nil?
    return user if user.password_match?(password)
    nil
  end

end
