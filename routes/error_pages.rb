#
# Displays 403 page if the request is forbidden
#
# @return [<slim>] <403 page>
#
def forbidden
    status 403
    slim :'generic/403'
end


#
# Displays 401 page if the user is not authenticated
#
# @return [<slim>] <401 page>
#
def unauthorized
    status 401
    slim :'generic/401'
end

# Displays 404 Not Found page if the route is not found
#
# @return [<slim>] <404 page>
#
not_found do
    slim :'generic/404'
end

# Displays 401 page if the user is not authenticated
#
# @return [<slim>] <401 page>
#
get '/auth-needed' do
    unauthorized
end