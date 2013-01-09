# Load the rails application
require File.expand_path('../application', __FILE__)

if %w(irb script/rails).include? $0 and not Rails.env.production?
  require 'hirb'
  Hirb.enable
end

# Initialize the rails application
Genie::Application.initialize!
