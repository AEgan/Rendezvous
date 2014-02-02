FactoryGirl.define do

	# user factory
	factory :user do
		first_name "Alex"
		last_name "Egan"
		provider "facebook"
		uid "1000000"
		oauth_token "1930124vaowe29da9nfsak0"
		oauth_expires_at Time.new(2014, 5, 5, 12, 30)
	end

end