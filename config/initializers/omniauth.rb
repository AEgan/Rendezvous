OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '1389041624692968', '48219b00b05afccc84fdff3d39832b47'
end