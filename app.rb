require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sassc'
require_relative 'utils'
require_relative 'database'
require_relative 'users/users'
set :port, 5000
set :bind, '0.0.0.0'
set :sessions, enable
also_reload 'database.rb', 'utils.rb', 'user/users.rb'

# CSS config for sass
get('/css/style.css') do
    scss :'scss/style', :style => :compressed
end

# Home page
get("/") do 
    top_10_videogames = VideoGame.all(10)
    slim(:index, locals: { videogames: top_10_videogames })
end


