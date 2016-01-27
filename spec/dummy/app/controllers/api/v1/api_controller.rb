module Api::V1

  class ApiController < ApplicationController

    prepend_before_filter :hmac_auth, :except => :auth

  end

end