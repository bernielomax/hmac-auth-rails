module ControllerMacros
  def user_hmac_auth
    before(:each) do
      hmac_mod = HmacAuthRails::HmacController
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")
      canonical_string = ",,/api/v1/users,#{date}"
      signature = hmac_mod.encrypt(user.secret_key, canonical_string)
      @request.env['Content-Type'] = "application/json"
      @request.env['HTTP_X_HMAC_AUTHORIZATION'] = "#{user.auth_token}:#{signature}"
      @request.env['HTTP_X_HMAC_DATE'] = date
      @request.env['HTTP_X_HMAC_CONTENT_MD5'] = "null"
      @request.env['HTTP_X_HMAC_CONTENT_TYPE'] = "null"
    end
  end
  def user_login
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.build(:user)
      sign_in :user, user
    end
  end
end