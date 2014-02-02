class User < ActiveRecord::Base
	# relationships
	has_many :events
	
	# validations
	validates_presence_of :provider, :uid, :first_name, :last_name, :oauth_token, :oauth_expires_at
	validates_time :oauth_expires_at
	validates_inclusion_of :provider, in: %w[facebook]

	# scopes
	scope :alphabetical, -> { order('last_name, first_name') }
	scope :expired, -> { where('oauth_expires_at <= ?', Time.now) }
	scope :active, -> { where('oauth_expires_at > ?', Time.now) }

	# methods
	# first last
	def name
		"#{first_name} #{last_name}"
	end

	# last first
	def ordered_name
		"#{last_name}, #{first_name}"
	end
	# black magic
	def self.from_omniauth(auth)
		where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
			user.provider = auth.provider
			user.uid = auth.uid
			user.first_name = auth.info.first_name
			user.last_name = auth.info.last_name
			user.oauth_token = auth.credentials.token
			user.oauth_expires_at = Time.at(auth.credentials.expires_at)
			user.save!
		end
	end
end
