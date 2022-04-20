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

post('/games/:id/review/add') do
    if session[:user_id].nil?
        unauthorized
    end

    not_found unless params[:id].to_i.positive?
    id = params[:id].to_i
    videogame = VideoGame.find(id)
    not_found unless videogame

    user = User.find(session[:user_id])
    not_found unless user

    rating = Rating.new(videogame.id, user.id, params[:rating].to_f)
    flash[:success] = "Rating successfully added!"
    redirect "/games/#{videogame.id}"
end