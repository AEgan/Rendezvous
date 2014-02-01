class Event < ActiveRecord::Base
	belongs_to :creater, class_name: "User", foreign_key: "user_id"

	# validations
	validates_numericality_of :user_id, only_integer: true, greater_than: 0, allow_blank: false
	validates_presence_of :name
	validates_presence_of :description
	validates_inclusion_of :active, in: [true, false], message: "Must be true or false"
	validates_numericality_of :longitude, allow_blank: true
	validates_numericality_of :latitude, allow_blank: true
	validates_time :start_time
	validates_time :end_time, on_or_after: :start_time

	# scopes
	# can add more later
	scope :for_user, ->(uid) { where('user_id = ?', uid)  }
	scope :by_start_time, -> { order('start_time DESC') }
	scope :by_end_time, -> { order('end_time DESC') }
	scope :current, -> { where('start_time <= ? AND ? <= end_time', Time.now, Time.now) }

end
