class UsersController < ApplicationController

  def demo
    @user = User.first
    sign_in :user, @user
  end

end
