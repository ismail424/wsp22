require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sassc'
require_relative './utils'

set :port, 5000
set :bind, '0.0.0.0'
set :sessions, enable
set :session_secret, 'super secret'

# CSS config for sass
get('/css/style.css') do
    scss :'scss/style', :style => :compressed
end

# Home page
get("/") do
    database = connect_to_db()
    videogames = database.execute("SELECT json_object('id', id, 'name', name, 'description', description, 'realse_date',realse_date) AS VideoGames FROM VideoGames LIMIT 1;")
    puts videogames
    slim(:index, locals: { videogames: videogames })
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