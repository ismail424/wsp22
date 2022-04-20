require 'bcrypt'
require 'sqlite3'
require_relative 'utils'

def db()
    database = SQLite3::Database.new 'db/database.db'
    database.results_as_hash = true
    database
end


# A class for all database methods and objects
class DbModel
    attr_reader :id, :hash
  
    def self.table_name
    end
    
    def table_name
        self.class.table_name
    end
  
    def initialize(data)
        @id = data['id']
    end

    def ==(other)
        return false if other.nil?
        @id == other.id
    end

  
    def self.find(id)
        data = db.execute("SELECT * FROM #{table_name} WHERE id = ?", id).first
        data && self.new(data)
    end
  
    def self.all(limit = nil)
        results = []
        if limit
            results = db.execute("SELECT * FROM #{table_name} LIMIT #{limit}")
        else
            results = db.execute("SELECT * FROM #{table_name}")
        end
        results.map {|data| self.new(data)}
    end 

	def gen_update_query(vars)
		out = vars.join " = ?, "
		out += " = ?"
	end

    def apply_filter(query, filter)
		if filter != "" then query += " WHERE #{filter}" end
		query
	end

    def update(data, filter="", *args) 
        q = "UPDATE #{table_name} SET #{self.gen_update_query(data.keys)} WHERE id = #{@id}" 
        q = self.apply_filter(q, filter)
        db.query(q, *data.values, *args)
    end

end

class User < DbModel
    attr_reader :profile_pic, :username, :email, :admin
    def self.table_name
        "Users"
    end

    def initialize(data)
        super data
        @profile_pic  = data['profile_pic'] || defautl_profile_pic 
        @username = data['username']
        @email = data['email']
        @password_hash = BCrypt::Password.new(data['password_hash'])
        @admin = data['admin'] || false
    end

    def authenticate(password)
        @password_hash == password
    end

    def defautl_profile_pic
        "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(@email)}?d=https%3A%2F%2Fui-avatars.com%2Fapi%2F/#{@username}/64"
    end

    def self.create_user(username, password, email, profile_pic = "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?d=https%3A%2F%2Fui-avatars.com%2Fapi%2F/#{username}/64", admin =false)
        session = db
        return nil if find_by_username(username)
        return nil if find_by_email(email)

        password_hash = BCrypt::Password.create(password)
        user = session.execute("INSERT INTO #{table_name} (profile_pic, username, password_hash, email, admin) VALUES (?, ?, ?, ?, ?)", profile_pic, username, password_hash, email, admin ? 1 : 0)
        
        session.last_insert_row_id
    end

    def self.find_by_username(username)
        data = db.execute("SELECT * FROM #{table_name} WHERE LOWER(username) = ?", username.downcase).first
        data && self.new(data)
    end

    def self.find_by_email(email)
        data = db.execute("SELECT * FROM #{table_name} WHERE email = ?", email).first
        data && self.new(data)
    end

    def self.validate( data )
 
        case data
            when data[:username]
                raise "Username must be at least 3 characters long" if data[:username].length < 3
                data[:username] = data[:username].gsub(VALID_USERNAME_REGEX,'')[0..13]

            when data[:email]
                raise "Invalid email address" unless data[:email] =~ VALID_EMAIL_REGEX
                data[:email] = data[:email][0..39]
            when data[:password]
                raise "Password must be at least 8 characters long" if data[:password].length < 7
                if data[:password_confirmation] 
                    raise "Passwords do not match" if data[:password] != data[:password_confirmation]
                end
                data[:password] = data[:password][0..19]
        end

        data
    end

    def delete_profile_pic
        full_path = File.join("public", @profile_pic)
        File.delete(full_path) if File.exist?(full_path)
        @profile_pic = defautl_profile_pic
        db.execute("UPDATE #{table_name} SET profile_pic = ? WHERE id = ?", @profile_pic, @id)
    end


    def get_reviews()
        Review.all(@id, limit)
    end

end

# A class for all database methods and objects
class VideoGame  < DbModel
    attr_reader :name, :description, :release_date, :genres, :platforms, :images, :rating_avg
    
    def self.table_name
        'VideoGames'
    end
    
    def initialize(data)
        super data
        @name = data['name']
        @description = data['description']
        @release_date = data['realse_date'] 
        @genres = self.get_genres
        @platforms = self.get_platforms
        @images = self.get_images
        @rating_avg = self.get_rating_avg
    end

    def self.search(name)
        results = []

        db.execute("SELECT * FROM #{table_name} WHERE name LIKE ?", "%#{name}%").each do |row|
            results << self.new(row)
        end

        results
    end

    def self.filter_by_genre(genre)
        results = []

        db.execute("SELECT * FROM #{table_name} WHERE genres LIKE ?", "%#{genre}%").each do |row|
            results << self.new(row)
        end

        results
    end

    def get_genres
        result = []
        
        db.execute("SELECT * FROM GenreToGame WHERE game_id = ?", @id).each do |row|
            result << Genre.find(row['genre_id'])
        end
        result
    end

    private def get_platforms
        result = []

        db.execute("SELECT * FROM PlatformToGame WHERE game_id = ?", @id).each do |row|
            result << Platform.find(row['platform_id'])
        end
        result
    end

    private def get_images
        result = []

        db.execute("SELECT * FROM Images WHERE game_id = ?", @id).each do |row|
            result << Image.find(row['id'])
        end
        result
    end
    
    def get_rating_avg
        avg_rating = db.execute("SELECT AVG(rating) AS average_rating FROM Rating WHERE game_id = ?", @id).first['average_rating']
        avg_rating.nil? ? 0 : avg_rating.round(1)
    end
end

# Streamers class
class Streamer < DbModel
    attr_reader :img_src, :streamer_name, :full_name, :age, :height, :description, :platform, :favorite_game
    def self.table_name
        'Streamers'
    end

    def initialize(data)
        super data
        @img_src = data['img_src']
        @streamer_name = data['streamer_name']
        @full_name = data['full_name']
        @age = data['age']
        @height = data['height']
        @description = data['description']
        @platform = data['platform']
        @favorite_game = data['favorite_game']
    end

end
  
# Genre class
class Genre < DbModel
    attr_reader :name
    
    def self.table_name
        'Genres'
    end
    
    def initialize(data)
        super data
        @name = data['name']
    end
end

# Platform class
class Platform < DbModel
    attr_reader :name

    def self.table_name
        'Platforms'
    end

    def initialize(data)
        super data
        @name = data['name']
    end
end

class Image < DbModel
    attr_reader :src

    def self.table_name
        'Images'
    end

    def initialize(data)
        super data
        @src = data['src']
    end

end

class Comment < DbModel

    attr_reader :titel, :body, :game_id

    def self.table_name
        'Comments'
    end

    def initialize(data)
        super data
        @titel = data['titel']
        @body = data['body']
        @game_id = data['game_id']
    end

end

class Rating < DbModel

    attr_reader :rating, :game_id

    def self.table_name
        'Rating'
    end

    def initialize(data)
        super data
        @rating = data['rating']
        @game_id = data['game_id']
    end

end


class Review

    attr_reader :titel, :body, :game_id, :rating, :user_id

    def initialize(data)
        super data
        @rating = data['rating']
        @titel = data['titel']
        @body = data['body']
        @game_id = data['game_id']
        @user_id = data['user_id']
    end

end