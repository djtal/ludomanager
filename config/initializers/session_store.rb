# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key => '_ludomanager_session',
  :secret      => '2cf8a0f58a5c99a57e6a326a6937971da5797cecb67c9e438a59d000de921e1eeb90796a7eadc6e84c9e3dfe21ba11b0e8dcd7df03761ef8d30d16083d8b6870'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
