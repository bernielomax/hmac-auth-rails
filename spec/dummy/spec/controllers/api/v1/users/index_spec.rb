require 'rails_helper'

RSpec.describe Api::V1::UsersController, :type => :controller do
  user_hmac_auth
  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
      get :index, :format => :json
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end
end

RSpec.describe Api::V1::UsersController, :type => :controller do
  user_login
  describe "GET #auth" do
    it "responds successfully with an HTTP 200 status code" do
      get :auth, :format => :json
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end
end
