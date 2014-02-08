require 'test_helper'

class AttendanceTest < ActiveSupport::TestCase
	# relationships
	should belong_to(:user)
	should belong_to(:event)

	# shouldas
	# validations
	should validate_numericality_of(:user_id).only_integer
	should validate_numericality_of(:event_id).only_integer

	# value tests
	# fks (limited without context)
	should_not allow_value("").for(:user_id)
	should_not allow_value(nil).for(:user_id)
	should_not allow_value("").for(:event_id)
	should_not allow_value(nil).for(:event_id)
	# confirmed
	should allow_value(true).for(:confirmed)
	should allow_value(false).for(:confirmed)
	should_not allow_value("").for(:confirmed)
	should_not allow_value(nil).for(:confirmed)

	context "creating context for testing attendances" do
		# set it up
		setup do
			# need users
	  	@alex = FactoryGirl.create(:user)
	  	@cory = FactoryGirl.create(:user, first_name: "Cory", last_name: "Chang")
	  	@dave = FactoryGirl.create(:user, first_name: "Dave", last_name: "Yan")
	  	@tony = FactoryGirl.create(:user, first_name: "Tony", last_name: "Romo")
	  	# need categories
	  	@chilling = FactoryGirl.create(:category)
	  	# need events
	  	@bored_uc = FactoryGirl.create(:event, creator: @cory, category: @chilling)
	  	@halo = FactoryGirl.create(:event, creator: @alex, category: @chilling, name: "Playing Halo", description: "Playing halo in Varun's room", start_time: Time.now + 20.minutes, end_time: Time.now + 3.hours)
	  	# attendances
	  	@dave_halo = FactoryGirl.create(:attendance, user: @dave, event: @halo, confirmed: false)
	  	@tony_halo = FactoryGirl.create(:attendance, user: @tony, event: @halo, confirmed: true)
	  	@dave_uc   = FactoryGirl.create(:attendance, user: @dave, event: @bored_uc, confirmed: true)
	  	@tony_uc   = FactoryGirl.create(:attendance, user: @tony, event: @bored_uc, confirmed: true)
		end
		# tear it down
		teardown do
			# users
			@alex.destroy
			@cory.destroy
			@dave.destroy
			@tony.destroy
			# categories
			@chilling.destroy
			# events
			@bored_uc.destroy
			@halo.destroy
			# attendances
			@dave_halo.destroy
			@tony_halo.destroy
			@dave_uc.destroy
			@tony_uc.destroy
		end

		# make sure the factories work for testing
		should "have working factories for testing" do
			# users
			assert_equal "Alex", @alex.first_name
			assert_equal "Cory", @cory.first_name
			assert_equal "Dave", @dave.first_name
			assert_equal "Tony", @tony.first_name
			# categories
			assert_equal "Hanging Out", @chilling.name
			# events
			assert_equal "Bored in UC", @bored_uc.name
			assert_equal "Playing Halo", @halo.name
			# attendances
			deny @dave_halo.confirmed
			assert @tony_halo.confirmed
			assert @dave_uc.confirmed
			assert @tony_uc.confirmed
		end

		# scopes
		# for user
		should "have a scope to return attendances for a user" do
			dave_attendances = Attendance.for_user(@dave.id)
			assert_equal 2, dave_attendances.size
			assert dave_attendances.include?(@dave_halo)
			assert dave_attendances.include?(@dave_uc)
			tony_attendances = Attendance.for_user(@tony.id)
			assert tony_attendances.include?(@tony_uc)
			assert tony_attendances.include?(@tony_halo)
		end

		# for event
		should "have a scope to return attendances for an event" do
			halo_attendances = Attendance.for_event(@halo)
			uc_attendances   = Attendance.for_event(@bored_uc)
			assert_equal 2, halo_attendances.size
			assert_equal 2, uc_attendances.size
			assert halo_attendances.include?(@tony_halo)
			assert halo_attendances.include?(@dave_halo)
			assert uc_attendances.include?(@tony_uc)
			assert uc_attendances.include?(@dave_uc)
		end

		# confirmed
		should "have a scope to return attendances that are confirmed" do
			confirmed_attendances = Attendance.confirmed
			assert_equal 3, confirmed_attendances.size
			assert confirmed_attendances.include?(@tony_halo)
			assert confirmed_attendances.include?(@tony_uc)
			assert confirmed_attendances.include?(@dave_uc)
			deny   confirmed_attendances.include?(@dave_halo)
		end

		# unconfirmed
		should "have a scope to return unconfirmed attendances" do
			unconfirmed_attendances = Attendance.unconfirmed
			deny   unconfirmed_attendances.include?(@tony_halo)
			deny   unconfirmed_attendances.include?(@tony_uc)
			deny   unconfirmed_attendances.include?(@dave_uc)
			assert unconfirmed_attendances.include?(@dave_halo)
		end

		# validations
		# user not in system would be caught with the shouldas above
		# event not active
		should "not allow an attendance to be created if the event is not active in the system" do
			inactive_event = FactoryGirl.create(:event, creator: @cory, name: 'Inactive', description: 'Pls do not work', active: false)
			bad_attendance = FactoryGirl.build(:attendance, user: @dave, event: inactive_event)
			deny bad_attendance.valid?
			inactive_event.destroy
		end
	end
end
