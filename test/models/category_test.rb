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

	context "testing categories with context" do
		# set up the context
		setup do
			@chilling = FactoryGirl.create(:category)
			@studying = FactoryGirl.create(:category, name: "Studying")
			@NSFW = FactoryGirl.create(:category, name: "NSFW", active: false)
		end

		# tear down the context
		teardown do
			@chilling.destroy
			@studying.destroy
			@NSFW.destroy
		end

		# make sure factories work for testing
		should "have working factories for testing" do
			assert_equal "Hanging Out", @chilling.name
			assert_equal "Studying", @studying.name
			assert_equal "NSFW", @NSFW.name
		end

		# scopes
		# active
		should "have a scope to return active categories" do
			active_cats = Category.active
			assert_equal 2, active_cats.size
			assert active_cats.include?(@chilling)
			assert active_cats.include?(@studying)
			deny active_cats.include?(@NSFW)
		end

		# inactive
		should "have a scope to return inactive scopes" do
			assert_equal [@NSFW], Category.inactive
		end

		# alphabetical
		should "have a scope to return categories in alphabetical order" do
			assert_equal [@chilling.name, @NSFW.name, @studying.name], Category.alphabetical.map { |category| category.name }
		end

		# validations
		# repeat
		should "not allow a category to be created with the same name" do
			case_sensitive = FactoryGirl.build(:category, name: "Studying")
			case_insensitive = FactoryGirl.build(:category, name: "StUdYiNg")
			deny case_sensitive.valid?
			deny case_insensitive.valid?
		end

		# no name
		should "not allow a category to be created without a name" do
			blank_name = FactoryGirl.build(:category, name: "")
			nil_name = FactoryGirl.build(:category, name: nil)
			deny blank_name.valid?
			deny nil_name.valid?
		end
	end

end
