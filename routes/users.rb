# Login Page
get("/login") do
    slim(:"account/login")
end

# Login form
post("/account/login") do
    @user = User.find_by_username(params[:username])
    if (!@user)
        flash[:error] = "No user with that username exists"
        redirect "/login"
    elsif (@user && @user.authenticate(params[:password]))
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
    @user = User.new(params[:user])
    if @user.save
        session[:user_id] = @user.id
        redirect "/"
    else
        flash[:error] = "Error creating user"
        redirect "/register"
    end
end