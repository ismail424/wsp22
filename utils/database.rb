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
end

class User < DbModel
    attr_reader :profile_pic, :username, :email, :admin
    def self.table_name
        "Users"
    end

    def initialize(data)
        super data
        @profile_pic = data['profile_pic'] || "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(data['email'])}?d=https%3A%2F%2Fui-avatars.com%2Fapi%2F/#{data['username']}/64"
        @username = data['username']
        @email = data['email']
        @password_hash =  data['password_hash']
        @admin = data['admin'] || false
    end

    def self.authenticate(password)
        @password_hash == BCrypt::Password.new(password)
    end

    def self.create_user(username, password, email, profile_pic = "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?d=https%3A%2F%2Fui-avatars.com%2Fapi%2F/#{username}/64", admin =false)
        session = db
        return nil if session.execute("SELECT * FROM #{table_name} WHERE username = ?", username).first
        

        password_hash = BCrypt::Password.create(password)
        user = session.execute("INSERT INTO #{table_name} (profile_pic, username, password_hash, email, admin) VALUES (?, ?, ?, ?, ?)", profile_pic, username, password_hash, email, admin ? 1 : 0)
        new_user_id = session.last_insert_row_id

        new_user_id
    end

    def self.find_by_username(username)
        data = db.execute("SELECT * FROM #{table_name} WHERE username = ?", username).first
        data && self.new(data)
    end

end


# A class for all database methods and objects
class VideoGame  < DbModel
    attr_reader :name, :description, :release_date, :genres, :platforms, :images
    
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