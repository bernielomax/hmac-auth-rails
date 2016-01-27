require 'rails_helper'

RSpec.describe "api/v1/users/auth", :type => :view do
  it "renders the users auth_token and secret_key" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = FactoryGirl.build(:user)
    render
    expect(rendered).to include(@user.auth_token)
    expect(rendered).to include(@user.secret_key)
  end
end

