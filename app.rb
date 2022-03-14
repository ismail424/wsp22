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
    top_10_videogames = VideoGame.all(10)
    slim(:index, locals: { videogames: top_10_videogames })
end

# Games Routes
get('/games') do
    limit = params[:limit] || 50
    videogames = VideoGame.all(limit != 'all' ? limit.to_i : nil)
    slim(:"games/index", locals: { videogames: videogames })
end
get('/games/:id') do
    id = params[:id].to_i
    videogame = VideoGame.find(id)
    slim(:"games/show", locals: { videogame: videogame })
end



# Streamers Routes
get('/streamers') do
    streamers = Streamer.all
    slim(:"streamers/index", locals: { streamers: streamers })
end

get('/streamers/:id') do
    id = params[:id].to_i
    streamer = Streamer.find(id)
    slim(:"streamers/show", locals: { streamer: streamer })
end