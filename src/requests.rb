require 'json'

# Request標準
class DefaultRequest
  attr_reader :message

  def initialize (message) 
    @message = message
  end
end

# Success汎用
class Success
  attr_reader :message
  attr_accessor :params

  def initialize (message, params=nil) 
    @message = message
    @params = params
  end

  def to_json()
    hash = {
      "status": "success",
      "message": @message,
      "params": @params
    }
    hash.to_json
  end
end


# Error汎用
class Error
  attr_reader :message

  def to_json()
    hash = {
      "status": "error",
      "message": @message
    }
    hash.to_json  
  end

end

