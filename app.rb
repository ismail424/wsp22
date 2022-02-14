require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require "sqlite3"
require 'sassc'
require_relative './utils'

set :port, 5000
set :bind, '0.0.0.0'
set :sessions, enable
set :session_secret, 'super secret'

get('/css/style.css') do
    scss :'scss/style', :style => :compressed
end

get("/") do
    database = connect_to_db()
    videogames = database.execute("SELECT * FROM VideoGames LIMIT 10;")
    return slim(:index, locals: { videogames: videogames })
end