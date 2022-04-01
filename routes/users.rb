# Login Page
get("/login") do
    slim(:"account/login")
end

# Login form
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

# Register form
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
get("/profile") do
    slim(:"account/profile")
end

get("/profile/edit") do
    slim(:"account/edit")
end

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


    if validation[:profile_pic] != ""
        filename = "#{@user.id}_#{validation[:profile_pic][:filename].to_s.gsub(/[^0-9A-Za-z.\-]/, '')}"
        path = "/img/profile_pics/#{filename}"
        full_path = File.join("public", path)

        File.open(full_path, 'wb') {|f| f.write validation[:profile_pic][:tempfile].read }
        validation[:profile_pic] = path
        
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


# Logout
get("/logout") do
    session.clear
    flash[:warning] = "You are now logged out"
    redirect "/"
end