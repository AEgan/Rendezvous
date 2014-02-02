require 'test_helper'

class EventTest < ActiveSupport::TestCase
	# shouldas
	#relationships
  should belong_to(:creator).class_name('User').with_foreign_key('user_id')

  # validations
  should validate_presence_of(:name)
  should validate_presence_of(:description)
  should validate_numericality_of(:user_id).only_integer
  should validate_numericality_of(:longitude)
  should validate_numericality_of(:latitude)

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
	  	@studying = FactoryGirl.create(:event, creator: @cory, name: "Studying", description: "Studying in Alex's Room", start_time: Time.now + 2.hours, end_time: nil)
	  	@inactive = FactoryGirl.create(:event, creator: @alex, name: "Inactive", description: "Hacking", start_time: Time.now + 5.hours, end_time: nil, active: false)
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
  end
end
