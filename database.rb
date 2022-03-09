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
    attr_reader :id
  
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
        database = db()
        data = database.execute("SELECT * FROM #{table_name} WHERE id = ?", id)[0]
        self.new(data)
    end
  
    def self.all(limit = nil)
        database = db()
        results = []
        if limit
            results = database.execute("SELECT * FROM #{table_name} LIMIT #{limit}")
        else
            results = database.execute("SELECT * FROM #{table_name}")
        end
        results.map {|data| self.new(data)}
    end  

end

# A class for all database methods and objects
class VideoGames < DbModel
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
        data && VideoGames.new(data)
    end
  
end
  
