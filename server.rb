$development = ENV['PRODUCT_ENV'] == 'development'

if $development
  require 'byebug'
  require 'sinatra/reloader' 
end

require 'json'
require 'sinatra/base'
require 'sinatra/cookies'
require 'line/bot'

require_relative 'src/db_util'
require_relative 'src/template'
require_relative 'src/beacon_allocator'
require_relative 'src/line_allocator'


class Server < Sinatra::Base
  set :port, 8080
  set :bind, "0.0.0.0"

  use Rack::Session::Cookie, {
    key: 'rack.session',
    expire_after: 60,
    secret: Digest::SHA256.hexdigest(rand.to_s)
  }


  get '/' do
    if $development
      "hoge"
    else
      error 400 do "Invalid Request" end
    end
  end

  # アカウント登録画面
  get '/register' do
    session[:line_id] = params['line_id']

    erb :register
  end

  # formのポスト先
  post '/submit' do
    name = params["name"]
    profile = params["profile"]
    line_id = session[:line_id]

    # TODO: error系をいい感じに画面にフィードしてredirect
    error 400 do "Field Lacking" end unless name && profile && line_id

    safe_params = {name: name, profile: profile, line_id: line_id}
    unless $line_allocator.register_user safe_params
      error 400 do "Invalid Params" end
    end

    redirect 'https://line.me/R/oaMessage/@jrs2532i', 307
  end


  # messaging APIの受け口
  post '/line' do
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless $client.validate_signature body, signature
      error 400 do "Bad Request" end
    end

    events = $client.parse_events_from(body)
    error 400 do "invalid json" end unless events

    case event
    when Line::Bot::Event::Follow
      puts "follow fire"
      $line_allocator.send_register event['source']['userId']

    when Line::Bot::Event::Beacon
      puts "beacon fire"
      $beacon_allocator.allocate_event event

    when Line::Bot::Event::Message
      puts "message fire"
      puts event
      $line_allocator.allocate_message event
      
    when Line::Bot::Event::Postback
      puts "postback get"
      puts event
      $line_allocator.allocate_postback event

    end

    "ok"
  end

end

def setup()
  cred = YAML.load_file("config/cred.yml")["channel"]

  # line bot
  $line_client ||= Line::Bot::Client.new do |config|
    config.channel_secret = cred["LINE_CHANNEL_SECRET"]
    config.channel_token = cred["LINE_CHANNEL_TOKEN"]
  end

  # allocator
  $line_allocator = LineAllocator.instance
  $beacon_allocator = BeaconAllocator.instance
  $templates = Template.instance
end

setup()
Server.run!
