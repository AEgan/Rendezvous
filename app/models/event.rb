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
	validates_presence_of :start_time
	# do these even work?
	validates_date :start_time, on_or_after: DateTime.now, on: :create, allow_blank: false
	validates_date :end_time, on_or_after: :start_time, allow_blank: true
	validates_date :start_time
	validate :creator_in_system
	validate :category_active_in_system
	validate :start_time_before_end_time
	validate :start_time_not_in_past, on: :create

	# scopes
	# can add more later
	scope :for_user, ->(uid) { where('user_id = ?', uid)  }
	scope :by_start_time, -> { order('start_time ASC') }
	scope :by_end_time, -> { order('end_time ASC') }
	scope :current, -> { where('start_time <= ? AND (end_time IS NULL OR ? <= end_time )', DateTime.now, DateTime.now) }
	scope :active, -> { where(active: true) }
	scope :inactive, -> { where(active: false) }
	scope :for_category, ->(cid) { where('category_id = ?', cid) }

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
	# why doesn't validates_date work properly?
	def start_time_before_end_time
		return true if self.start_time.nil?
		unless self.end_time.nil? or self.start_time < self.end_time
			errors.add(:end_time, "must be before start time")
			return false
		end
		true
	end

	def start_time_not_in_past
		return true if self.start_time.nil?
		unless self.start_time > DateTime.now - 2.seconds
			errors.add(:start_time, "can not be in the past")
			return false
		end
		true
	end
end
