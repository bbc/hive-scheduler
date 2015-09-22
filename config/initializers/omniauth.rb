Rails.application.config.force_authentication = false
Rails.application.config.default_omniauth_provider = :none

Rails.application.config.middleware.use OmniAuth::Builder do
#  provider :developer unless Rails.env.production?
end
