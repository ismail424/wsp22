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
    puts VideoGames.all(10)
    # slim(:index, locals: { videogames: videogames })
    "Hello World"
end

# Games Routes
get('/games') do
    database = connect_to_db()
    videogames = database.execute('SELECT * FROM VideoGames')
    slim(:"games/index", locals: { videogames: videogames })
end
get('/games/:id') do
    id = params[:id].to_i
    database = connect_to_db()
    videogame = database.execute('SELECT * FROM VideoGames WHERE id = ?', id)[0]
    slim(:"games/show", locals: { videogame: videogame })
end