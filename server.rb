require 'json'
require 'byebug'

require 'sinatra/base'
require 'sinatra/reloader' 

require 'line/bot'

require_relative 'src/requests'
require_relative 'src/db_util'

require_relative 'src/beacon_allocator'
require_relative 'src/line_allocator'
require_relative 'src/template'
require_relative 'src/message_helper'


class Hoge < Sinatra::Base
  set :port, 8080
  set :bind, "0.0.0.0"

  get '/' do
    "hoge"
  end

  get '/register' do
    @line_id = params["line_id"]
    erb :register
  end

  post '/submit' do
    name = params["name"]
    profile = params["profile"]
    line_id = params["line_id"]

    req = validate_existance({"name":name, "profile":profile, "line_id": line_id})
    return req.to_json if req.class==Error

    puts params

    safe_params = {"name": name, "profile": profile, "line_id": line_id}
    $line_allocator.register_user(safe_params)
    
    #redirect 'https://line.me/R/', 302
    redirect 'https://line.me/R/oaMessage/@jrs2532i', 307
  end


  # line beacon API
  post '/line' do
    req = request.body.read

    params = parse_json req
    return Error.new("invalid json") unless params
    return Error.new("require event") unless event=params.dig("events")[0]

    puts event

    case event["type"]
    when "follow" then
      puts "follow fire"
      $line_allocator.send_register(event.dig("source", "userId"))

    when "beacon" then
      puts "beacon fire"
      res = $beacon_allocator.allocate_event(event)

    when "message" then
      puts "message fire"
      puts params
      res = $line_allocator.allocate_event(event["source"]["userId"], event)
      
    when "postback" then
      puts "postback get"

      params = parse_json event["postback"]["data"]
      return Error.new("invalid json") unless params

      puts params

      case params["type"]
      when "invite"
        puts "get invite"
        $line_allocator.send_invite event["source"]["userId"], params["user_id"]

      when "matching"
        puts "get matching"
        $line_allocator.pairing(event["source"]["userId"], params["user_id"])
      end
      
    else
      res = Error.new("invalid type")

    end


    return res.to_json
  end

end

# parse Json text
# text / nil
def parse_json(text)
  params = nil
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
    next if v

    return Error.new("#{k} required")
  end

  return nil
end

def setup()
  cred = YAML.load_file("config/cred.yml")["channel"]

  # line bot
  $line_client ||= Line::Bot::Client.new { |config|
    config.channel_secret = cred["LINE_CHANNEL_SECRET"]
    config.channel_token = cred["LINE_CHANNEL_TOKEN"]
  }

  # allocator
  $line_allocator = LineAllocator.instance
  $beacon_allocator = BeaconAllocator.instance
  $templates = Template.instance
  $message_helper = MessageHelper.instance
end

setup()
Hoge.run!
