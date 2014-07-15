json.array!(@profiles) do |profile|
  json.extract! profile, :id, :user_token, :fb_token, :pic_url, :name, :surname, :phone, :iban, :reg_num, :birthday, :company_name, :email, :password, :salt, :created_at, :updated_at
  json.url profile_url(profile, format: :json)
end
