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


end
