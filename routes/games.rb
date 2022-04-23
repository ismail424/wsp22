# Displayes all the games in the database.
#
# @param :limit [Integer]  The number of games to display
#
# @see VideoGame
#
# @return [<slim>] <all games page>
#
get('/games') do
    limit = params[:limit] || 50
    videogames = VideoGame.all(limit != 'all' ? limit.to_i : nil)
    slim(:"games/index", locals: { videogames: videogames })
end


# Displayes only one game with given id
#
# @param :id [Integer]  The id of the game to display
#
# @see VideoGame
#
# @return [<slim>] <game with specific id page>
get('/games/:id') do
    not_found unless params[:id].to_i.positive?
    id = params[:id].to_i
    videogame = VideoGame.find(id)
    not_found unless videogame
    slim(:"games/show", locals: { videogame: videogame })
end
