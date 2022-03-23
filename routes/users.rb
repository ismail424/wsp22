# Login and Register
get("/login") do
    slim(:"account/login")
end
get("/register") do
    slim(:"account/register")
end