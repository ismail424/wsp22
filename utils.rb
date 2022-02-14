require 'bcrypt'
require 'sqlite3'


def connect_to_db()
    database = SQLite3::Database.new 'db/database.db'
    database.results_as_hash = true
    database
end