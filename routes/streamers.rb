# Streamers Routes
get('/streamers') do
    streamers = Streamer.all
    slim(:"streamers/index", locals: { streamers: streamers })
end

get('/streamers/:id') do
    not_found unless params[:id].to_i.positive?
    id = params[:id].to_i
    streamer = Streamer.find(id)
    not_found unless streamer
    slim(:"streamers/show", locals: { streamer: streamer })
end