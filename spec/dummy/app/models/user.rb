class User < ActiveRecord::Base

  hmac_authenticatable

  after_initialize :generate_key, :generate_token

  devise :database_authenticatable

  protected
  def generate_token
    self.auth_token ||= loop do
      random_token = SecureRandom.hex(32)
      break random_token unless User.exists?(auth_token: random_token)
    end
  end

  def generate_key
    self.secret_key  ||= SecureRandom.base64(64)
  end

end
