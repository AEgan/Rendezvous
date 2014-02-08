require 'test_helper'

class EventTest < ActiveSupport::TestCase
	# shouldas
	#relationships
  should belong_to(:creator).class_name('User').with_foreign_key('user_id')
  should have_many(:attendances)
  should have_many(:users).through(:attendances)
  should belong_to(:category)

  # validations
  should validate_presence_of(:name)
  should validate_presence_of(:description)
  should validate_numericality_of(:user_id).only_integer
  should validate_numericality_of(:longitude)
  should validate_numericality_of(:latitude)
  should validate_numericality_of(:category_id).only_integer

  # allow values...
  # longitude
  # good
  should allow_value(3.14159).for(:longitude)
  should allow_value(-5.9876).for(:longitude)
  should allow_value(0).for(:longitude)
  should allow_value(50).for(:longitude)
  should allow_value("").for(:longitude)
  should allow_value(nil).for(:longitude)
  # bad
  should_not allow_value("hello world").for(:longitude)
  # latitude
  # bad
  should allow_value(3.14159).for(:latitude)
  should allow_value(-5.9876).for(:latitude)
  should allow_value(0).for(:latitude)
  should allow_value(50).for(:latitude)
  should allow_value("").for(:latitude)
  should allow_value(nil).for(:latitude)
  # bad
  should_not allow_value("hello world").for(:latitude)

  # tried to do 'true' for longitude and latitude but the conversion of boolean to float failed and caused an error
  # so boom you can't use that!

  # active
  # good
  should allow_value(true).for(:active)
  should allow_value(false).for(:active)
  #bad
  should_not allow_value("").for(:active)
  should_not allow_value(nil).for(:active)

  # start time
  # good
  should allow_value(Time.now).for(:start_time)
  should allow_value(Time.now + 1.minute).for(:start_time)
  should allow_value(Time.now + 2.days).for(:start_time)
  # bad
  should_not allow_value(Time.now - 1.minute).for(:start_time)
  should_not allow_value(nil).for(:start_time)
  should_not allow_value("").for(:start_time)

  # limited tests for end time
  should allow_value(nil).for(:end_time)
  should allow_value("").for(:end_time)

  context "creating context to test events " do
  	# set it up
  	setup do
	  	# need users
	  	@alex = FactoryGirl.create(:user)
	  	@cory = FactoryGirl.create(:user, first_name: "Cory", last_name: "Chang")
	  	# events
	  	@bored_uc = FactoryGirl.create(:event, creator: @cory)
	  	@halo = FactoryGirl.create(:event, creator: @alex, name: "Playing Halo", description: "Playing halo in Varun's room", start_time: Time.now + 20.minutes, end_time: Time.now + 3.hours)
	  	@inactive = FactoryGirl.create(:event, creator: @alex, name: "Inactive", description: "Hacking", start_time: Time.now + 5.hours, end_time: Time.now + 7.hours, active: false)
	  	@studying = FactoryGirl.create(:event, creator: @cory, name: "Studying", description: "Studying in Alex's Room", start_time: Time.now + 2.hours, end_time: nil)
  	end
  	# tear it down
  	teardown do
  		# users
  		@alex.destroy
  		@cory.destroy
  		# events
  		@bored_uc.destroy
  		@halo.destroy
  		@studying.destroy
  		@inactive.destroy
  	end
  	# make sure factories are working
  	should "have working factories for testing" do
  		assert_equal @alex.first_name, "Alex"
  		assert_equal @cory.first_name, "Cory"
  		assert_equal @bored_uc.name, "Bored in UC"
  		assert_equal @halo.name, "Playing Halo"
  		assert_equal @studying.name, "Studying"
  		assert_equal @inactive.name, "Inactive"
  	end

  	# scopes
  	# for user
  	should "have a scope that returns events for a given user" do
  		alex_events = Event.for_user(@alex.id)
  		cory_events = Event.for_user(@cory.id)
  		assert_equal 2, alex_events.size
  		assert_equal 2, cory_events.size
  		assert alex_events.include?(@halo)
  		assert alex_events.include?(@inactive)
  		assert cory_events.include?(@bored_uc)
  		assert cory_events.include?(@studying)
  	end

  	# by start date
  	should "have a scope to return events by start date" do
  		assert_equal ["Bored in UC", "Playing Halo", "Studying", "Inactive"], Event.by_start_time.map { |event| event.name }
  	end

  	# by end time
  	should "have a scope to return events by end time" do
  		assert_equal ["Studying", "Bored in UC", "Playing Halo", "Inactive"], Event.by_end_time.map { |event| event.name }
  	end

  	# current
  	should "have a scope to return current events" do
  		# changing the start time to check if the end date was nil
  		@studying.update_attribute(:start_time, Time.now - 1.hour)
  		@studying.save!
  		current_events = Event.current
  		assert current_events.include?(@bored_uc)
  		assert current_events.include?(@studying)
  	end

  	# active
  	should "have a scope to return active events" do
  		active_events = Event.active
  		assert_equal 3, active_events.size
  		assert active_events.include?(@halo)
  		assert active_events.include?(@bored_uc)
  		assert active_events.include?(@studying)
  		deny active_events.include?(@inactive)
  	end

  	# inactive
  	should "have a scope to return inactive events" do
  		assert_equal [@inactive], Event.inactive
  	end

  	# validations
  	# end time before start time
  	should "not allow end time to be before start time" do
  		bad_dates = FactoryGirl.build(:event, creator: @alex, name: "Invalid", description: "This shouldn't be valid", start_time: Time.now+20.minutes, end_time: Time.now + 2.minutes)
  		deny bad_dates.valid?
  	end

  	# creator not in the system
  	should "not allow an event to be created if the user is not in the system" do
  		no_user = FactoryGirl.build(:event, creator: nil, name: "Invalid", description: "don't work")
  		deny no_user.valid?
  		# don't really know how to test this with a user not in the system because the belongs_to is creator and there is no user_id...
  	end 

  end
end
