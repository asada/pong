class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate

  private
  def authenticate
    if !Rails.env.test? && user && pass
      authenticate_or_request_with_http_basic do |username, password|
        username == user && password == pass
      end
    end
  end

  def user
    @user ||= ENV["username"]
  end

  def pass
    @pass ||= ENV["password"]
  end
end
