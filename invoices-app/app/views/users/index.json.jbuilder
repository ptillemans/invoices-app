json.array!(@users) do |user|
  json.extract! user, :id, :username, :admin, :reader
  json.url user_url(user, format: :json)
end
