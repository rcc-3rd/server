require 'byebug'

require 'json'
require 'sinatra/base'
require 'sinatra/reloader' 
require 'line/bot'

require_relative 'src/db_util'
require_relative 'src/template'
require_relative 'src/beacon_allocator'
require_relative 'src/line_allocator'


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

    validate_existance({"name":name, "profile":profile, "line_id": line_id})
    error 400 do 'field lacking' end unless res

    safe_params = {"name": name, "profile": profile, "line_id": line_id}
    $line_allocator.register_user(safe_params)
    
    #redirect 'https://line.me/R/', 302
    redirect 'https://line.me/R/oaMessage/@jrs2532i', 307
  end


  # line beacon API
  post '/line' do
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless $client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = $client.parse_events_from(body)
    error 400 do 'invalid json' end unless events

    case event["type"]
    when "follow" then
      puts "follow fire"
      $line_allocator.send_register(event.dig("source", "userId"))

    when "beacon" then
      puts "beacon fire"
      $beacon_allocator.allocate_event(event)

    when "message" then
      puts "message fire"
      puts params
      res = $line_allocator.allocate_event(event["source"]["userId"], event)
      
    when "postback" then
      puts "postback get"

      params = parse_json event["postback"]["data"]
      error 400 do 'invalid postback json' end unless params

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
      error 400 do 'unsupported postback type' end
    end

    "ok"

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
# true(ok) / false(err)
def valide_existance(params)
  params.each do |k, v|
    next if v

    return false
  end

  return true
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
end

setup()
Hoge.run!
