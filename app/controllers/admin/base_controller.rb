class Admin::BaseController < ApplicationController
  layout 'admin'

  private

  def authenticate
    user = ENV["admin_username"]
    pass = ENV["admin_password"]
    unless Rails.env.test?
      authenticate_or_request_with_http_basic do |username, password|
        username == user && password == pass
      end
    end
  end
end
