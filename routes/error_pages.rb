def forbidden
    status 403
    slim :'generic/403'
end


def unauthorized
    status 401
    slim :'generic/401'
end

not_found do
    slim :'generic/404'
end

get '/auth-needed' do
    unauthorized
end