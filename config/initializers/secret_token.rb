# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Hive::Scheduler::Application.config.secret_key_base = 'ca572ca06f36f3bf9519a115598dad2f96a12905e0c2a41381ed8d6a9e93752c2996956931cdc0d874be8ac2c656b84c67f3a8fd07d690734fc3f1807bc8b3c3'
