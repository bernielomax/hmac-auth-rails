json.users do
  json.array!(@users) do |user|
    json.id user.id
    json.email user.email
    json.auth_token user.auth_token
  end
end