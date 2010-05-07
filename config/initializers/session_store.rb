# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_nrsr_session',
  :secret      => '1f4388ab8b82bc0154f3ada73e26dacf5deb8b816a1222aa0e9e4ca0ddb77a902bc489467143b7f59b994087a618bd828b5a113927825e7a6a6f82bc2c79aad2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
