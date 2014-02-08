require 'test_helper'

class UserTest < ActiveSupport::TestCase
	# relationships
	should have_many(:created_events).class_name('Event')
	should have_many(:attendances)
	should have_many(:events).through(:attendances)

	# validations
	should validate_presence_of(:first_name)
	should validate_presence_of(:last_name)
	should validate_presence_of(:uid)
	should validate_presence_of(:provider)
	should validate_presence_of(:oauth_token)
	should validate_presence_of(:oauth_expires_at)

	# shouldas for provider
	should allow_value('facebook').for(:provider)
	should_not allow_value('twitter').for(:provider)
	should_not allow_value('google').for(:provider)
	should_not allow_value(232).for(:provider)
	should_not allow_value("").for(:provider)
	should_not allow_value(nil).for(:provider)
	# testing with contxt
	context "creating context to test users" do
		# set up the context
		setup do
			@alex = FactoryGirl.create(:user)
			@ryan = FactoryGirl.create(:user, first_name: 'Ryan', oauth_expires_at: DateTime.now - 1.day)
			# I needed a name that comes before Egan, so I went with a high school classmate who also happens to have a first name of 4 characters
			@mike = FactoryGirl.create(:user, first_name: 'Mike', last_name: 'Abate', oauth_expires_at: DateTime.now + 2.weeks)
		end
		# tear down the context
		teardown do
			@alex.destroy
			@ryan.destroy
			@mike.destroy
		end

		# makes sure factories work
		should "have working factories for testing" do
			assert_equal @alex.first_name, "Alex"
			assert_equal @ryan.first_name, "Ryan"
			assert_equal @mike.first_name, "Mike"
		end

		# testing scopes
		# alphabetical
		should "have a scope to return students in alphabetical order" do
			assert_equal ["Mike", "Alex", "Ryan"], User.alphabetical.map { |user| user.first_name }
		end

		# expired scope
		should "have a scope to return students whose oauth token has expired" do
			assert_equal [@ryan], User.expired
		end

		# active scope
		should "have a scope to return students whos oauth token has not expired" do
			active_users = User.active
			assert_equal 2, active_users.size
			assert active_users.include?(@alex)
			assert active_users.include?(@mike)
			deny active_users.include?(@ryan)
		end

		# methods
		# first last
		should "have a name method that gets the users first and last name" do
			assert_equal "Alex Egan", @alex.name
			assert_equal "Ryan Egan", @ryan.name
			assert_equal "Mike Abate", @mike.name
		end

		#last first
		should "have a method to return users name in last, first format" do
			assert_equal "Egan, Alex", @alex.ordered_name
			assert_equal "Egan, Ryan", @ryan.ordered_name
			assert_equal "Abate, Mike", @mike.ordered_name
		end
	end

end
