json.auth do
  json.auth_token @user[@user.auth_token_field]
  json.secret_key @user[@user.secret_key_field]
end