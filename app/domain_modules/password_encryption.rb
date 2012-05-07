require 'digest'

module PasswordEncryption

  def encrypt_password
    self.encrypted_password = encrypt(password) 
  end

  def make_salt
    secure_hash("#{Time.now.utc}--#{self.password}")
  end

  def encrypt(str)
    secure_hash("#{self.salt}--#{str}")
  end

  def secure_hash(str)
    Digest::SHA2.hexdigest(str)
  end

end
