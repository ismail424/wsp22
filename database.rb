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
        @hash = data
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

# A class for all database methods and objects
class VideoGame  < DbModel
    attr_reader :name
    
    def self.table_name
        'VideoGames'
    end
    
    def initialize(data)
        super data
        @name = data['name']
        @description = data['description']
        @release_date = data['realse_date'] 
    end

    def self.find_by_name(name)
        return nil if name.empty?
  
        data = db.execute("SELECT * FROM #{table_name} WHERE email = ?", name).first
        data && VideoGame.new(data)
    end

    def genres
        result = []
        db.execute("SELECT * FROM GenreToGame WHERE game_id = ?", @id).each do |row|
            result << Genre.find(row['genre_id'])
        end
        result
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