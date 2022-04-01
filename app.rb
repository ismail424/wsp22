require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'slim'
require 'sassc'


# Require all the routes and utils files
Dir[File.join(__dir__, 'utils', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'routes', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'utils', '*.rb')].each { |file| also_reload file }

set :port, 5000
set :bind, '0.0.0.0'
set :sessions, enable

# Before filter to check if user is logged in
before do
    if session[:user_id]
        @user = User.find(session[:user_id])
    end
end

# CSS config for sass
get('/css/style.css') do
    scss :'scss/style', :style => :compressed
end

# Home page
get("/") do 
    top_10_videogames = VideoGame.all(10)
    slim(:index, locals: { videogames: top_10_videogames })
end



