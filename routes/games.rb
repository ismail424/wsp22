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