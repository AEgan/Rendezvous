module ApplicationHelper
	# Stringifies time to make it look nice
	def time_stringify(time)
		time.strftime("%A, %B %e at %l:%M%P")
	end
end
