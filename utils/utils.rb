# Constants 
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
VALID_USERNAME_REGEX = /[^|A-Za-z0-9]+/

module Utils
    def temp_session(symbol)
      value = session[symbol]
      session.delete(symbol)
      value
    end

    def status(symbol)
      status = temp_session(symbol)
      status ? status : 200
    end

end