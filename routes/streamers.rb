# Displays all the streamers from the database.
#
# @see Streamer
#
# @return [<slim>] <all streamers page>
#
get('/streamers') do 
    streamers = Streamer.all
    slim(:"streamers/index", locals: { streamers: streamers })
end

# Displays streamer with given id.
#
# @param [Integer] :id, The id of the streamer to display
#
# @see Streamer
#
# @return [<slim>] <streamer with given id page>
#
get('/streamers/:id') do
    not_found unless params[:id].to_i.positive?
    id = params[:id].to_i
    streamer = Streamer.find(id)
    not_found unless streamer
    slim(:"streamers/show", locals: { streamer: streamer })
end