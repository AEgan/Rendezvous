class Event < ActiveRecord::Base
	belongs_to :creator, class_name: "User", foreign_key: "user_id"
	has_many :attendences
	has_many :users, through: :attendences

	# validations
	validates_numericality_of :user_id, only_integer: true, greater_than: 0, allow_blank: false
	validates_presence_of :name
	validates_presence_of :description
	validates_inclusion_of :active, in: [true, false], message: "Must be true or false"
	validates_numericality_of :longitude, allow_blank: true
	validates_numericality_of :latitude, allow_blank: true
	# the 2 seconds are for the delay that seems to be causing errors every now and again
	validates_time :start_time, on_or_after: Time.now-2.seconds, on: :create, allow_blank: false
	validates_time :end_time, on_or_after: :start_time, allow_blank: true
	validate :creator_in_system

	# scopes
	# can add more later
	scope :for_user, ->(uid) { where('user_id = ?', uid)  }
	scope :by_start_time, -> { order('start_time ASC') }
	scope :by_end_time, -> { order('end_time ASC') }
	scope :current, -> { where('start_time <= ? AND (end_time IS NULL OR ? <= end_time )', Time.now, Time.now) }

	# methods
	private
	# make sure the creater is actually in the system
	def creator_in_system
		creator_ids = User.all.map { |user| user.id }
		unless creator_ids.include?(self.user_id)
			errors.add(:creator, 'is not active in the system')
			return false
		end
		true
	end
end
