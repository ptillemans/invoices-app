require 'active_support/core_ext/numeric/bytes'
# Just use the production settings
require File.expand_path('../production.rb', __FILE__)

Rails.application.configure do
  # Settings specified here will take precedence over those in config/environemnts/production.rb.

  config.rack_cas.server_url = ENV['CAS_SERVER'] || 'https://cas.melexis.com:8443/cas'
  config.rack_cas.extra_attributes_filter = %w(Name Email Telephone)


end
