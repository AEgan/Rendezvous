require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
	# shouldas
	# relationships
	should have_many(:events)

	# validations
	should validate_presence_of(:name)
	should validate_uniqueness_of(:name).case_insensitive

	# allow values
	should allow_value(true).for(:active)
	should allow_value(false).for(:active)
	should_not allow_value("").for(:active)
	should_not allow_value(nil).for(:active)

end
