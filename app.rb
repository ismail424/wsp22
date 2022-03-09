require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sassc'
require_relative 'utils'
require_relative 'database'
set :port, 5000
# set :bind, '0.0.0.0'
set :sessions, enable

also_reload 'database.rb', 'utils.rb'

# CSS config for sass
get('/css/style.css') do
    scss :'scss/style', :style => :compressed
end

# Home page
get("/") do 
    VideoGame.find(5).genres.to_s
    # slim(:index, locals: { videogames: videogames })
end

# Games Routes
get('/games') do
    videogames = VideoGame.all(10)
    slim(:"games/index", locals: { videogames: videogames })
end
get('/games/:id') do
    id = params[:id].to_i
    videogames = VideoGame.find(id)
    slim(:"games/show", locals: { videogame: videogame })
end