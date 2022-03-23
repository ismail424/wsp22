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