OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '1439276546305351', '6251ba1a97393f1efd068f0a64161c77'
end