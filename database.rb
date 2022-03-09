require 'bcrypt'
require 'sqlite3'
require_relative 'utils'

def db()
    database = SQLite3::Database.new 'db/database.db'
    database.results_as_hash = true
    database
end

class VideoGames
    # Get all videogames from the database 
    # params: limit (int, deafult: 10), random (bool, default: false)
    # @return [Array] videogames
    def self.get(limit = 10, random = false)
        if random == true
            return db.execute("SELECT * FROM VideoGames ORDER BY RANDOM() LIMIT ?;", limit)
        end
        
        db.execute('SELECT * FROM VideoGames LIMIT ?', limit)
    end

end



class DBmodel