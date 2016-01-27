require "spec_helper"

RSpec.describe "users/demo.html.erb" do
  it "Displays all users and their auth tokens" do
    render
    expect(response.body).to match /Auth Tokens/m
  end
end

