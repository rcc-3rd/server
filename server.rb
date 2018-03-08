require 'json'

require 'sinatra/base'
require 'sinatra/reloader' 

require_relative 'src/requests'
require_relative 'src/db_util'



class Hoge < Sinatra::Base
  set :port, 8080
  set :bind, "0.0.0.0"

  get '/' do
    "hoge"
  end

  post '/submit' do
    params = JSON.parse request.body.read
    return Error.new("invalid json") unless params

    name = params.dig("name")
    profile = params.dig("profile")

    req = validate_existance({"name":name, "profile":profile})
    return req.to_json if req.class==Error

    # should validate

    safe_params = {"name": name, "profile": profile}
    register_user(safe_params)

    return Success.new("submit done").to_json 
  end


# line beacon API
  post '/beacon' do
    params = parse_json request.body.read
    return Error.new("invalid json")
    
    return {"status": "hoge"}.to_json
  end
end

def register_user(params)

end

# parse Json text
# text / nil
def parse_json(text)
  begin
    params = JSON.parse text
  rescue JSON::ParserError
    return nil
  end

  params
end


# 存在検証
# Error / nil
def validate_existance(params)
  params.each do |k, v|
    continue if v

    return Error.new("#{k} required")
  end

  return nil
end

def setup()
  # line bot
  # db  
end

setup()
Hoge.run!
