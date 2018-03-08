require 'json'

require 'sinatra/base'
require 'sinatra/reloader' 

require_relative 'src/requests'
require_relative 'src/db_util'

require_relative 'src/beacon_allocator'
require_relative 'src/line_allocator'


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
    line_id = params.dig("line_id")

    req = validate_existance({"name":name, "profile":profile, "line_id": line_id})
    return req.to_json if req.class==Error

    # should validate

    safe_params = {"name": name, "profile": profile, "line_id": line_id}
    register_user(safe_params)

    return Success.new("submit done").to_json 
  end


  # line beacon API
  post '/line' do
    params = JSON.parse request.body.read
    return Error.new("invalid json") unless params
    return Error.new("require event") unless event=params.dig("events")[0]

    puts params

    case event["type"]
    when "beacon" then
      res = $beacon_allocator.allocate_event(event)

    when "message" then
      res = $line_allocator.allocate_event(event)

    else
      res = Error.new("invalid type")

    end
    
    return res.to_json
  end


end

# validateしてから読んでねてへぺろ
def register_user(params)
  params["active"] = 1

  user = User.create(params)
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
  # allocator
  $line_allocator = LineAllocator.getInstance()
  $beacon_allocator = BeaconAllocator.getInstance()
end

#setup()
Hoge.run!
