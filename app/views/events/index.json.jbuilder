json.array!(@events) do |event|
  json.extract! event, :id, :name, :description, :latitude, :longitude, :start_time, :end_time, :active, :user_id
  json.url event_url(event, format: :json)
end
