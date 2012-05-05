module PasswordEncryption

  def encrypt_password
    self.encrypted_password = encrypt(password) 
  end

  def encrypt(str)
    str
  end

end
