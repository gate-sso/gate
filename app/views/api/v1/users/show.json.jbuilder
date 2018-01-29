json.(@user, :email, :uid, :name, :active, :admin, :home_dir, :shell, :public_key, :user_login_id, :product_name)
json.groups @user.groups, :gid, :name
