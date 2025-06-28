class Api::V1::BaseController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  before_action :authenticate_user!

  private

  def authenticate_user!
    authenticate_or_request_with_http_basic do |username, password|
      expected_username = ENV.fetch("API_USERNAME")
      expected_password = ENV.fetch("API_PASSWORD")

      username == expected_username && password == expected_password
    end
  end
end
