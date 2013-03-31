# Load the rails application
require File.expand_path('../application', __FILE__)

if %w(irb script/rails).include? $0 and not Rails.env.production?
  require 'hirb'
  Hirb.enable output: {
    'Problem' => { options: { filters: {
      digest:   lambda { |s| '<binary>' },
      solution: lambda { |s| '<binary>' }
    }}},
    'Answer' => { options: { filters: {
      content: lambda { |s| '<binary>' }
    }}}
  }
end

# Initialize the rails application
Genie::Application.initialize!
