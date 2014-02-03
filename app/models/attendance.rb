class Attendance < ActiveRecord::Base
	# relationships
	belongs_to :user
	belongs_to :event

	# validations
	validates_numericality_of :user_id, only_integer: true, allow_blank: false
	validates_numericality_of :event_id, only_integer: true, allow_blank: false
	validates_inclusion_of :confirmed, in: [true, false]
	validate :user_in_system
	validate :event_active_in_system

	# scopes
	scope :for_user, ->(uid) { where('user_id = ?', uid) }
	scope :for_event, ->(eid) { where('event_id = ?', eid) }
	scope :confirmed, -> { where(confirmed: true) }
	scope :unconfirmed, -> { where(confirmed: false) }

	# methods
	private
	# make sure user is in the system
	def user_in_system
		# seems risky, but will be caught by numericality validations and if this isn't here it blows up
		# my shoulda matchers in attendance_test.rb
		return true if self.user_id.nil?
		user_ids = User.all.map { |user| user.id }
		unless user_ids.include?(self.user_id)
			errors.add(:user, 'is not recognized by the system')
			return false
		end
		true
	end

	# make sure the event is active in the system
	def event_active_in_system
		# seems risky, but will be caught by numericality validations and if this isn't here it blows up
		# my shoulda matchers in attendance_test.rb
		return true if self.event_id.nil?
		event_ids = Event.active.map { |event| event.id }
		unless event_ids.include?(self.event_id)
			errors.add(:event, 'is not active in the system')
			return false
		end
		true
	end
end
