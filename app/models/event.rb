class Event < ActiveRecord::Base
	# relationships
	belongs_to :creator, class_name: "User", foreign_key: "user_id"
	belongs_to :category
	has_many :attendances
	has_many :users, through: :attendances

	# validations
	validates_numericality_of :user_id, only_integer: true, greater_than: 0, allow_blank: false
	validates_numericality_of :category_id, only_integer: true, greater_than: 0, allow_blank: false
	validates_presence_of :name
	validates_presence_of :description
	validates_inclusion_of :active, in: [true, false], message: "Must be true or false"
	validates_numericality_of :longitude, allow_blank: true
	validates_numericality_of :latitude, allow_blank: true
	# the 2 seconds are for the delay that seems to be causing errors every now and again
	validates_time :start_time, on_or_after: lambda { DateTime.now - 1.minute }, on: :create, allow_blank: false
	validates_time :end_time, on_or_after: :start_time, allow_blank: true
	validate :creator_in_system
	validate :category_active_in_system

	# scopes
	# can add more later
	scope :for_user, ->(uid) { where('user_id = ?', uid)  }
	scope :by_start_time, -> { order('start_time ASC') }
	scope :by_end_time, -> { order('end_time ASC') }
	scope :current, -> { where('start_time <= ? AND (end_time IS NULL OR ? <= end_time )', DateTime.now, DateTime.now) }
	scope :active, -> { where(active: true) }
	scope :inactive, -> { where(active: false) }

	# methods
	private
	# make sure the creater is actually in the system
	def creator_in_system
		creator_ids = User.all.map { |user| user.id }
		unless creator_ids.include?(self.user_id)
			errors.add(:creator, 'is not recognized by the system')
			return false
		end
		true
	end
	# make sure category is active in the system
	def category_active_in_system
		return true if self.category_id.nil?
		category_ids = Category.active.map { |category| category.id }
		unless category_ids.include?(self.category_id)
			errors.add(:category, ' is not active in the system')
			return false
		end
		true
	end
end
