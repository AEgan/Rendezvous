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
  should validate_presence_of(:start_time)

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

  # # start time
  # # good
  # should allow_value(DateTime.now).for(:start_time)
  # should allow_value(DateTime.now + 1.minute).for(:start_time)
  # should allow_value(DateTime.now + 2.days).for(:start_time)
  # # bad
  # should_not allow_value(DateTime.now - 1.minute).for(:start_time)
  # should_not allow_value(nil).for(:start_time)
  # should_not allow_value("").for(:start_time)

  # limited tests for end time
  should allow_value(nil).for(:end_time)
  should allow_value("").for(:end_time)

  context "creating context to test events " do
  	# set it up
  	setup do
	  	# need users
	  	@alex = FactoryGirl.create(:user)
	  	@cory = FactoryGirl.create(:user, first_name: "Cory", last_name: "Chang")
      # categories
      @chilling = FactoryGirl.create(:category)
      @studying_cat = FactoryGirl.create(:category, name: "Studying")
	  	# events
	  	@bored_uc = FactoryGirl.create(:event, creator: @cory, category: @chilling)
	  	@halo = FactoryGirl.create(:event, creator: @alex, category: @chilling, name: "Playing Halo", description: "Playing halo in Varun's room", start_time: DateTime.now + 20.minutes, end_time: DateTime.now + 3.hours)
	  	@inactive = FactoryGirl.create(:event, creator: @alex, category: @studying_cat, name: "Inactive", description: "Hacking", start_time: DateTime.now + 5.hours, end_time: DateTime.now + 7.hours, active: false)
	  	@studying = FactoryGirl.create(:event, creator: @cory, category: @studying_cat, name: "Studying", description: "Studying in Alex's Room", start_time: DateTime.now + 2.hours, end_time: nil)
  	end
  	# tear it down
  	teardown do
  		# users
  		@alex.destroy
  		@cory.destroy
      # categories
      @chilling.destroy
      @studying_cat.destroy
  		# events
  		@bored_uc.destroy
  		@halo.destroy
  		@studying.destroy
  		@inactive.destroy
  	end
  	# make sure factories are working
  	should "have working factories for testing" do
      # users
  		assert_equal @alex.first_name, "Alex"
  		assert_equal @cory.first_name, "Cory"
      # categories
      assert_equal @chilling.name, "Hanging Out"
      assert_equal @studying_cat.name, "Studying"
      # events
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
  		@studying.update_attribute(:start_time, DateTime.now - 1.hour)
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

    # for category
    should "have a scope to return events that are associated with a given category" do
      chilling_events = Event.for_category(@chilling.id)
      studying_events = Event.for_category(@studying_cat.id)
      assert_equal 2, chilling_events.size
      assert_equal 2, studying_events.size
      assert chilling_events.include?(@bored_uc)
      assert chilling_events.include?(@halo)
      assert studying_events.include?(@studying)
      assert studying_events.include?(@inactive)
    end

  	# validations
  	# end time before start time
  	should "not allow end time to be before start time" do
  		bad_dates = FactoryGirl.build(:event, creator: @alex, category: @chilling, name: "Invalid", description: "This shouldn't be valid", start_time: DateTime.now+20.minutes, end_time: DateTime.now + 2.minutes)
  		deny bad_dates.valid?
  	end

  	# creator not in the system
  	should "not allow an event to be created if the user is not in the system" do
  		no_user = FactoryGirl.build(:event, creator: nil, category: @chilling, name: "Invalid", description: "don't work")
  		deny no_user.valid?
  		# don't really know how to test this with a user not in the system because the belongs_to is creator and there is no user_id...
  	end 

    # bad values for start date
    should "not allow values for start date that are blank, nil, or before the current time " do
      late = FactoryGirl.build(:event, creator: @alex, category: @chilling, name: "L8", description: "start time in past", start_time: DateTime.now - 1.minute, end_time: DateTime.now + 1.hour)
      deny late.valid?
      blank = FactoryGirl.build(:event, creator: @alex, category: @chilling, name: "blank", description: "start time is blank", start_time: "", end_time: DateTime.now + 1.hour)
      deny blank.valid?
      is_nil = FactoryGirl.build(:event, creator: @alex, category: @chilling, name: "nil", description: "start time is nil", start_time: nil, end_time: DateTime.now + 1.hour)
      deny is_nil.valid?
      is_string = FactoryGirl.build(:event, creator: @alex, category: @chilling, name: "string", description: "start time is string", start_time: "string", end_time: DateTime.now + 1.hour)
      deny is_string.valid?
    end

    # good values for start date
    should "allow date values in the future or present for start date" do
      current = FactoryGirl.build(:event, creator: @alex, category: @chilling, name: "Current", description: "start time is current", start_time: DateTime.now, end_time: DateTime.now + 5.hours)
      assert current.valid?
      future = FactoryGirl.build(:event, creator: @alex, category: @chilling, name: "Future", description: "start time is in the future", start_time: DateTime.now + 2.hours, end_time: DateTime.now + 5.hours)
      assert future.valid?
    end

  end
end
