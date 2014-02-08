FactoryGirl.define do

	# user factory
	factory :user do
		first_name "Alex"
		last_name "Egan"
		provider "facebook"
		uid "1000000"
		oauth_token "1930124vaowe29da9nfsak0"
		oauth_expires_at DateTime.now + 4.months
	end

	# event factory
	factory :event do
		association :creator
		association :category
		name "Bored in UC"
		description "Come chill in the US with my I'm bored"
		start_time DateTime.now
		end_time DateTime.now + 1.hour
		active true
		latitude 40.444513
		longitude -79.94234
	end

	# attendance factory
	factory :attendance do
		association :user
		association :event
		confirmed false
	end

	# category factory
	factory :category do
		name "Hanging Out"
		active true
	end
end