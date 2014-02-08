class Category < ActiveRecord::Base
	# relationships
	has_many :events

	# validations
	validates_presence_of :name
	validates_uniqueness_of :name, case_sensitive: false
	validates_inclusion_of :active, in: [true, false]

	# scopes
	scope :alphabetical, -> { order('name') }
	scope :active, -> { where(active: true) }
	scope :inactive, -> { where(active: false) }
end
