require 'json'

require 'sinatra/base'
require 'sinatra/reloader' 

require 'line/bot'

require_relative 'src/requests'
require_relative 'src/db_util'

require_relative 'src/beacon_allocator'
require_relative 'src/line_allocator'
require_relative 'src/template'


class Hoge < Sinatra::Base
  set :port, 8080
  set :bind, "0.0.0.0"

  get '/' do
    "hoge"
  end

  get '/register' do
    erb :register
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
    $line_client.register_user(safe_params)

    return Success.new("submit done").to_json 
  end


  # line beacon API
  post '/line' do
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless $line_client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = $line_client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Beacon
        $beacon_allocator.allocate_event(event)

      when Line::Bot::Event::Message
=begin
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          $line_client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
=end
      when Line::Bot::Event::Follow
        $line_allocator.send_register()
      end
    end

    return res.to_json
  end

  # 「誘う」が押されてお誘いを送信
  get 'invite' do
    user_id = params["user_id"]
    target_id = params["target_id"]
    res = validate_existance({"user_id": user_id, "target_id": target_id})
    return res.to_json if res

    $line_client.send_invite(user_id, target_id)
  end

  # お誘いについて返答した時の処理
  get '/matching' do
    state = params["state"]
    return Error.new("state require") unless state

    case state
    when "no" 
      return Success.new("no")
    when "yes"
      user_id = params["user_id"]
      return Error.new("user_id required") unless user_id

      target_id = params["target_id"]
      return Error.new("target_id required") unless target_id
    
      # 諸々に問題がなければペアリング
      return $lineAllocator.pairing(user_id, target_id)
    end
  end

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
