Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  provider :facebook, '8296674194', ENV['FB_SECRET']
  provider :linked_in, 'CONSUMER_KEY', 'CONSUMER_SECRET'
end
