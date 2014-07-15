# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.delivery_method = :smtp;

ActionMailer::Base.smtp_settings = {
    :address => "localhost",
    :port => 25,
    :domain => "chargebutton.com",
    :authentication => :login,
    :user_name => "rails",
    :password => "rails"
}