require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'securerandom'
require 'rmagick'
require 'slim'
require 'sassc'

# Require all the routes and utils files
Dir[File.join(__dir__, 'utils', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'routes', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'utils', '*.rb')].each { |file| also_reload file }

set :port, 5000
set :bind, '0.0.0.0'
set :sessions, enable
include Utils

auth_needed = %w[/profile/edit /profile]
ignored_paths = %w[/style.css /favicon.ico /auth-needed]
auth_paths = %w[/login /register /auth-needed]

# Before the HTTP response is sent, check if user is authenticated
#
before do
    # Stroing the user in the session if he is logged in
    if session[:user_id]
        @user = User.find(session[:user_id])
    end

    status temp_session(:status_code) if session[:status_code]
    return if ignored_paths.include? request.path_info

    if !session[:user_id] && auth_needed.map { |path| request.path_info.start_with?(path) }.any?
        puts "User not logged in, redirecting to login page"
        session[:return_to] = request.fullpath
        session[:status_code] = 403
        redirect '/auth-needed'
    end

    (auth_paths.include? request.path_info) || session.delete(:return_to)
end

# CSS routes (sass stylesheet)
#
# @return [<css>] <css>
#
get('/css/style.css') do
    scss :'scss/style', :style => :compressed
end


# Display the home page
#
# @return [<slim>] <index page>
#
get("/") do   
    top_10_videogames = VideoGame.all(10)
    slim(:index, locals: { videogames: top_10_videogames })
end



