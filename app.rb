require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'

set :port, 5000
set :bind, '0.0.0.0'
set :sessions, enable


get("/") do
    return slim(:index)
end