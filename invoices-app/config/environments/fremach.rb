require 'active_support/core_ext/numeric/bytes'
# Just use the production settings
require File.expand_path('../production.rb', __FILE__)

Rails.application.configure do
  # Settings specified here will take precedence over those in config/environemnts/production.rb.

end
