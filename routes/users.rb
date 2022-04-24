# Displays the login page
#
# @return [<slim>] <login page>
#
get("/login") do
    slim(:"account/login")
end

# Attempts to login.
#
# @param [User] user The user to login.
# 
# @see User
# 
# @return [<slim>] <home page> if login is successful 
#
post("/login") do
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
        flash[:success] = "You are now logged in"
        session[:user_id] = user.id
        redirect "/"
    else
        flash[:error] = "Invalid username or password"
        session[:username] = params[:username]
        redirect "/login"
    end
end

# Register Page
get("/register") do
    slim(:"account/register")
end

# Attempts to register a new user.
#
# @param [String] username, The username of the user
# @param [String] email, The email of the user
# @param [String] password, The password of the user
# @param [String] password_confirmation, The password confirmation of the user
# 
# @see User
# 
# @return [<slim>] <home page> if account successfully registered
#
post("/register") do
    
    begin
        validation = User.validate(params)
    rescue => e
        flash[:error] = e
        redirect "/register"
    end
    
    user_id  = User.create_user(validation[:username], validation[:password], validation[:email])

    if !user_id.nil?
        session[:user_id] = user_id
        redirect "/"
    else
        flash[:error] = "Username or email already exists"
        session[:old_data] = params
        redirect "/register"
    end

end


# Profile Page
#
# @return [<slim>] <profile page>
#
get("/profile") do
    slim(:"account/profile")
end

# Displays the edit profile page
#
# @return [<slim>] <edit profile page> 
#
get("/profile/edit") do
    slim(:"account/edit")
end


## Attempts to edit the profile
#
# @param [File] avatar, The avatar of the user
# @param [String] username, The new username of the user
# @param [String] email, The new email of the user
# @param [String] password, The new password of the user
# @param [String] password_confirmation, The new password confirmation of the user
# 
# @see User
# 
# @return [<slim>] <profile page> if account successfully edited
#
post("/profile/edit") do

    begin
        validation = User.validate(params)
    rescue => e
        flash[:error] = e
        redirect "/profile/edit"
    end

    check_username, check_email = User.find_by_username(validation[:username]), User.find_by_email(validation[:email])
    unless check_username.nil? || check_username.id == @user.id
        flash[:error] = "Username already exists"
        redirect "/profile/edit"
    end
    unless check_email.nil? || check_email.id == @user.id
        flash[:error] = "Email already exists"
        redirect "/profile/edit"
    end


    if validation[:profile_pic]
        # File upload
        filename = "#{@user.id}_#{SecureRandom.uuid}.jpg"
        
        # Save profilepic route to database
        path = "/img/profile_pics/#{filename}"

        # Save profilepic to public folder /img/profile_pics
        full_path = File.join("public", path)
        img_data = validation[:profile_pic][:tempfile].read
        image = Magick::Image.from_blob(img_data).first
        image.format = 'jpeg'
        File.open(full_path, 'wb') do |f| 
            image.resize_to_fit(128, 128).write(f)
        end
        validation[:profile_pic] = path

        # Delete old profile pic
        @user.delete_profile_pic
    end
    
    if validation[:password] != "" 
        validation[:password_hash] = BCrypt::Password.create(validation[:password])
    end
    
    validation.delete(:password_confirmation)
    validation.delete(:password)
    
    @user.update(validation)
    
    flash[:success] = "Profile updated"
    redirect "/profile"
end


#  Logout
#
# @return [<slim>] <home page>
get("/logout") do
    session.clear
    flash[:warning] = "You are now logged out"
    redirect "/"
end