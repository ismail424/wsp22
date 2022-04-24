require 'bcrypt'
require 'sqlite3'
require_relative 'utils'

#
# Connects to the database
#
# @return [SQLite3::Database] The connection to the database
#
def db()
    database = SQLite3::Database.new 'db/database.db'
    database.results_as_hash = true
    database
end



#
# Database model
#
class DbModel
    attr_reader :id, :hash
  
    #
    # Gets tablename from class
    #
    # @return [<String>] <table name>
    #
    def self.table_name
    end
    
    #
    # Gets tablename from class (for objects only)
    #
    # @return [<String>] <table name>
    #
    def table_name
        self.class.table_name
    end
  
    #
    # Initializes the object
    #
    # @param [<Hash>] data, The data of the object
    #
    def initialize(data)
        @id = data['id']
    end

    #
    #  Validates the data of the object
    #
    # @param [<Object>] other, The data of the object 
    #
    # @return [<Bool>] <Returns if object match>
    #
    def ==(other)
        return false if other.nil?
        @id == other.id
    end

  
    #
    # Finds an object by id
    #
    # @param [<Integer>] id The id of the object
    #
    # @return [<Object>] <The object>
    #
    def self.find(id)
        data = db.execute("SELECT * FROM #{table_name} WHERE id = ?", id).first
        data && self.new(data)
    end
  
    #
    # Finds all objects
    #
    # @param [<limit>] limit <limit filter>
    # @param [<id>] id <id filter>
    #
    # @return [<Array>] <Aray with objects>
    #
    def self.all(limit = nil, id= nil )
        results = []
        query = "SELECT * FROM #{table_name}"

        if id != nil
            query += " WHERE id = #{id}"
        end

        if limit != nil
            query += " LIMIT #{limit}"
        end

        db.execute(query).each do |row|
            results << self.new(row)
        end

        results
    end 

    #
    # Creates an object
    #
    # @param [<Hash>] data, The data of the object
    #
    # @return [<Integer>] <The id of the new object>
    #
    def self.create(data)
        q = "INSERT INTO #{table_name} (#{data.keys.join(", ")}) VALUES (#{data.keys.map { |key| "?" }.join(", ")})"
        db.query(q, *data.values)
        self.find(db.last_insert_row_id)
    end

    #
    # Generates the update query
    #
    # @param [<Array>] data, The data of the object
    #
    # @return [<String>] <The update query>
    #
	def gen_update_query(vars)
		out = vars.join " = ?, "
		out += " = ?"
	end

    #
    # Applies filter to the query
    #
    # @param [<String>] query The query to apply the filter to
    # @param [<String>] filter The filter to apply
    #
    # @return [<String>] <The query with the filter>
    #
    def apply_filter(query, filter)
		if filter != "" then query += " WHERE #{filter}" end
		query
	end

    #
    # Updates the object
    #
    # @param [<Hash>] data, The data of the object
    # @param [<String>] filter, The filter to apply to the query
    # @param [<String>] filter, The filter to apply to the query
    #
    # @return [<SQLite3::Database>] <The connection to the database>
    #
    def update(data, filter="", *args) 
        q = "UPDATE #{table_name} SET #{self.gen_update_query(data.keys)} WHERE id = #{@id}" 
        q = self.apply_filter(q, filter)
        db.query(q, *data.values, *args)
    end

    #
    # Deletes the object
    #
    # @return [<SQLite3::Database>] <The connection to the database>
    #
    def delete
        q = "DELETE FROM #{table_name} WHERE id = #{@id}"
        db.query(q)
    end

end

#
# User model
#
class User < DbModel
    attr_reader :profile_pic, :username, :email, :admin, :reviews
    #
    # Returns table name
    #
    # @return [<String>] <The table name>
    #
    def self.table_name
        "Users"
    end

    #
    # Initializes the object
    #
    # @param [<Hash>] data, The data of the object
    #
    def initialize(data)
        super data
        @profile_pic  = data['profile_pic'] || defautl_profile_pic 
        @username = data['username']
        @email = data['email']
        @password_hash = BCrypt::Password.new(data['password_hash'])
        if data['admin'] == 1 then @admin = true else @admin = false end
        @reviews = self.get_reviews
    end

    #
    # Authenticates the user
    #
    # @param [<String>] password, The password of the user
    #
    # @return [<Bool>] <Returns if user is authenticated>
    #
    def authenticate(password)
        @password_hash == password
    end

    #
    # Returns the default profile_pic
    #
    # @return [<String>] <The default profile_pic>
    #
    def defautl_profile_pic
        "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(@email)}?d=https%3A%2F%2Fui-avatars.com%2Fapi%2F/#{@username}/64"
    end

    #
    # Creates a user
    #
    # @param [<String>] username, The username of the user
    # @param [<String>] email, The email of the user
    # @param [<String>] password, The password of the user
    # @param [<String>] profile_pic, The profile_pic of the user
    # @param [<Bool>] admin, The admin of the user
    # 
    # @return [<Type>] <description>
    #
    def self.create_user(username, password, email, profile_pic = "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?d=https%3A%2F%2Fui-avatars.com%2Fapi%2F/#{username}/64", admin =false)
        session = db
        return nil if find_by_username(username)
        return nil if find_by_email(email)

        password_hash = BCrypt::Password.create(password)
        user = session.execute("INSERT INTO #{table_name} (profile_pic, username, password_hash, email, admin) VALUES (?, ?, ?, ?, ?)", profile_pic, username, password_hash, email, admin ? 1 : 0)
        
        session.last_insert_row_id
    end

    #
    # Finds user by username
    #
    # @param [<String>] username, The username of the user
    #
    # @return [<User>] <The user>
    #
    def self.find_by_username(username)
        data = db.execute("SELECT * FROM #{table_name} WHERE LOWER(username) = ?", username.downcase).first
        data && self.new(data)
    end

    #
    # Finds user by email
    #
    # @param [<String>] email, The email of the user
    #
    # @return [<User>] <The user>
    #
    def self.find_by_email(email)
        data = db.execute("SELECT * FROM #{table_name} WHERE email = ?", email).first
        data && self.new(data)
    end

    #
    # Validates the user
    #
    # @param [<Hash>] data, The data of the user
    #
    # @return [<Bool>] <Returns if the user is valid>
    #
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

    #
    # Deletes profile_pic
    #
    def delete_profile_pic
        full_path = File.join("public", @profile_pic)
        File.delete(full_path) if File.exist?(full_path)
        @profile_pic = defautl_profile_pic
        db.execute("UPDATE #{table_name} SET profile_pic = ? WHERE id = ?", @profile_pic, @id)
    end

    #
    # Gets all reviews
    #
    # @return [<Array>] <The reviews>
    #
    private def get_reviews
        result = []

        db.execute("SELECT * FROM Review WHERE user_id = ?", @id).each do |row|
            result << Review.new(row)
        end

        result

    end
end

# 
# VideoGame model
#
class VideoGame  < DbModel
    attr_reader :name, :description, :release_date, :genres, :platforms, :images, :rating_avg, :reviews
    
    #
    # Table name
    #
    # @return [<String>] <The table name>
    #
    def self.table_name
        'VideoGames'
    end
    
    #
    # Initializes the object
    #
    # @param [<Hash>] data, The data of the object
    #
    def initialize(data)
        super data
        @name = data['name']
        @description = data['description']
        @release_date = data['realse_date'] 
        @genres = self.get_genres
        @platforms = self.get_platforms
        @images = self.get_images
        @rating_avg = self.get_rating_avg
        @reviews = self.get_reviews
    end

    #
    # Searches for a game
    #
    # @param [<String>] query, The query to search for
    #
    # @return [<Array>] <The game>
    #
    def self.search(name)
        results = []

        db.execute("SELECT * FROM #{table_name} WHERE name LIKE ?", "%#{name}%").each do |row|
            results << self.new(row)
        end

        results
    end

    #
    # Filter by genre
    #
    # @param [<String>] query, The query to search for
    #
    # @return [<Array>] <The game>
    #
    def self.filter_by_genre(genre)
        results = []

        db.execute("SELECT * FROM #{table_name} WHERE genres LIKE ?", "%#{genre}%").each do |row|
            results << self.new(row)
        end

        results
    end

    #
    # Gets all genres
    #
    # @return [<Array>] <The genres>
    #
    def get_genres
        result = []
        
        db.execute("SELECT * FROM GenreToGame WHERE game_id = ?", @id).each do |row|
            result << Genre.find(row['genre_id'])
        end
        result
    end

    #
    # Gets all platforms
    #
    # @return [<Array>] <The platforms>
    #
    private def get_platforms
        result = []

        db.execute("SELECT * FROM PlatformToGame WHERE game_id = ?", @id).each do |row|
            result << Platform.find(row['platform_id'])
        end
        result
    end

    #
    # Gets all images
    #
    # @return [<Array>] <The images>
    #
    private def get_images
        result = []

        db.execute("SELECT * FROM Images WHERE game_id = ?", @id).each do |row|
            result << Image.find(row['id'])
        end
        result
    end
    
    #
    # Gets the average rating of the game
    #
    # @return [<Float>] <The average rating>
    #
    private def get_rating_avg
        avg_rating = db.execute("SELECT AVG(rating) AS average_rating FROM Review WHERE game_id = ?", @id).first['average_rating']
        avg_rating.nil? ? 0 : avg_rating.round(1)
    end 

    #
    # Gets all reviews
    #
    # @return [<Array>] <The reviews>
    #
    private def get_reviews
        result = []

        db.execute("SELECT * FROM Review WHERE game_id = ?", @id).each do |row|
            result << Review.new(row)
        end

        result

    end

end

#
# Streamer model
#
class Streamer < DbModel
    attr_reader :img_src, :streamer_name, :full_name, :age, :height, :description, :platform, :favorite_game
    #
    # Table name
    #
    # @return [<String>] <The table name>
    #
    def self.table_name
        'Streamers'
    end

    #
    # Initializes the object
    #
    # @param [<Hash>] data, The data of the object
    #
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
  
#
# Genres model
#
class Genre < DbModel
    attr_reader :name
    #
    # Table name
    #
    # @return [<String>] <The table name>
    #
    def self.table_name
        'Genres'
    end

    #
    # Initializes the object
    #
    # @param [<Hash>] data, The data of the object
    #
    def initialize(data)
        super data
        @name = data['name']
    end
end


#
# Platform model
#
class Platform < DbModel
    attr_reader :name
    
    #
    # Table name
    #
    # @return [<String>] <The table name>
    #
    def self.table_name
        'Platforms'
    end

    #
    # Initializes the object
    #
    # @param [<Hash>] data, The data of the object
    #
    def initialize(data)
        super data
        @name = data['name']
    end
end

#
# Image model
#
class Image < DbModel
    attr_reader :src

    #
    # Table name
    #
    # @return [<String>] <The table name>
    #
    def self.table_name
        'Images'
    end

    #
    # Initializes the object
    #
    # @param [<Hash>] data, The data of the object
    #
    def initialize(data)
        super data
        @src = data['src']
    end

end

#
# Review model
#
class Review < DbModel
   
    #
    # Table name
    #
    # @return [<String>] <The table name>
    #
    attr_reader :rating, :comment, :user_id, :game_id
    
    def self.table_name
        'Review'
    end

    #
    # Initializes the object
    #
    # @param [<Hash>] data, The data of the object
    #
    def initialize(data)
        super data
        @rating = data['rating']
        @comment = data['comment']
        @user_id = data['user_id']
        @game_id = data['game_id']
    end

end