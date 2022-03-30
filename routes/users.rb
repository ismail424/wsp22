# Login Page
get("/login") do
    slim(:"account/login")
end

# Login form
post("/account/login") do
    @user = User.find_by_username(params[:username])
    if @user && @user.authenticate(params[:password])
        flash[:success] = "You are now logged in"
        session[:user_id] = @user.id
        redirect "/"
    else
        flash[:error] = "Invalid username or password"
        redirect "/login"
    end
end

# Register Page
get("/register") do
    slim(:"account/register")
end

# Register form
post("/account/register") do
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    username = params[:username].gsub(/[^|a-z0-9]+/,'')[0..19]
    email = params[:email][0..39]
    password = params[:password][0..19]
    password_confirmation = params[:password_confirmation][0..19]

    if (username.length < 3)
        flash[:error] = "Username must be at least 3 characters long"
        redirect "/register"
    end

    if password != password_confirmation
        flash[:error] = "Passwords do not match"
        redirect "/register"
    end

    unless email =~ VALID_EMAIL_REGEX 
        flash[:error] = "Invalid email address"
        redirect "/register"
    end
    

    user_id  = User.create_user(username, password, email)
    
    if user_id != nil
        session[:user_id] = user_id
        redirect "/"
    else
        flash[:error] = "Error creating user"
        redirect "/register"
    end


end


# Profile Page
get("/profile") do
    slim(:"account/profile")
end


# Logout
get("/logout") do
    session.clear
    flash[:success] = "You are now logged out"
    redirect "/"
end