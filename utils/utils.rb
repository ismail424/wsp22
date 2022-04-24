
# @return [String] Email validation Regex
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

# @return [String] Username validation Regex
VALID_USERNAME_REGEX = /[^|A-Za-z0-9]+/

#
# Class to handle common functions
#
module Utils
    #
    # Temp session data
    #
    # @param [String] key, The key of the session data
    #
    # @return [String] The value of the session data
    #
    def temp_session(symbol)
      value = session[symbol]
      session.delete(symbol)
      value
    end

    #
    # Checks if the user is logged in
    #
    # @param [User] user, The user to check if they are logged in
    #
    # @return [Boolean] Whether or not the user is logged in
    #
    def status(symbol)
      status = temp_session(symbol)
      status ? status : 200
    end

end