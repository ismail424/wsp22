get('/games') do
    limit = params[:limit] || 50
    videogames = VideoGame.all(limit != 'all' ? limit.to_i : nil)
    slim(:"games/index", locals: { videogames: videogames })
end
get('/games/:id') do
    not_found unless params[:id].to_i.positive?
    id = params[:id].to_i
    videogame = VideoGame.find(id)
    not_found unless videogame
    slim(:"games/show", locals: { videogame: videogame })
end


post('/games/:id/rating/add/:rating') do

    puts "params are #{params}"
    "params are #{params}"
end