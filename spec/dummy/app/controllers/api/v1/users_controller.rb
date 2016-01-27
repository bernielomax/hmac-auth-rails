module Api::V1
  class UsersController < ApiController

    def index
      @users = User.all
    end

    def auth
      @user = current_user.nil? ? User.first : current_user
    end

  end
end