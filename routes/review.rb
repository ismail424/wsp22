# Atemps to add a review to a game
#
# @param :rating [Integer] The rating of the game
# @param :comment [String] The comment of the game
# @param :user_id [Integer] The id of the user who added the review
# @param :game_id [Integer] The id of the game to add the review to
#
# @see Review
#
# @return [<slim>] <game page with the review added> 
#
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

    rating = params[:rating].to_i
    comment = params[:review_text]
    
    if comment.empty?
        flash[:error] = "Comment field is required."
        redirect "/games/#{videogame.id}"
    end

    if rating > 10 || rating < 1
        flash[:error] = "Rating must be between 1 and 10."
        redirect "/games/#{videogame.id}"
    end

    data = {
        :rating => rating,
        :comment => comment,
        :user_id => session[:user_id],
        :game_id => id
    }

    Review.create(data)
    
    flash[:success] = "Rating successfully added!"
    redirect "/games/#{videogame.id}"
end

# Displays the review to edit.
#
# @param :review_id [Integer] The id of the review to edit.
#
# @see Review
#
# @return [<slim>] <edit review page>
#
get('/games/:id/review/edit/:review_id') do
    if session[:user_id].nil?
        unauthorized
    end
    review = Review.find(params[:review_id])
    notfound unless review
    
    slim(:'reviews/edit', locals: { review: review })
end

# Atempts to edit a review.
#
# @param :review_id [Integer] The id of the review to edit.
# @param :rating [Integer] The rating of the game
# @param :comment [String] The comment of the game
#
# @see Review
#
# @return [<slim>] <game page with the review edited>
#
post('/games/:id/review/edit/:review_id') do
    if session[:user_id].nil?
        unauthorized
    end

    not_found unless params[:id].to_i.positive?

    videogame = VideoGame.find(params[:id].to_i)
    not_found unless videogame

    user = User.find(session[:user_id])
    not_found unless user

    review = Review.find(params[:review_id].to_i)
    not_found unless review

    if review.user_id != user.id && user.admin != true
        unauthorized
    end

    rating = params[:rating].to_i
    comment = params[:review_text]

    if comment.empty?
        flash[:error] = "Comment field is required."
        redirect "/games/#{videogame.id}"
    end

    if rating > 10 || rating < 1
        flash[:error] = "Rating must be between 1 and 10."
        redirect "/games/#{videogame.id}"
    end

    data = {
        :rating => rating,
        :comment => comment,
    }

    review.update(data)    
    flash[:success] = "Rating successfully edited!"
    redirect "/games/#{videogame.id}/review/edit/#{review.id}"
end



# Atempts to delete a review.
# 
# @param :review_id [Integer] The id of the review to delete.
#
# @see Review
#
# @return [<slim>] <game page with the review deleted>
#
get('/games/:id/review/delete/:review_id') do
    if session[:user_id].nil?
        unauthorized
    end

    not_found unless params[:id].to_i.positive?

    videogame = VideoGame.find(params[:id].to_i)
    not_found unless videogame

    user = User.find(session[:user_id])
    not_found unless user

    review = Review.find(params[:review_id].to_i)
    not_found unless review

    if review.user_id != user.id && user.admin != true
        unauthorized
    end

    review.delete
    
    flash[:success] = "Rating successfully removed!"
    redirect "/games/#{videogame.id}"
end


