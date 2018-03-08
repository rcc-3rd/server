require 'singleton'
require 'faraday'
require 'yaml'

class MessageHelper
  include Singleton

  def initialize
    cred = YAML.load_file("config/cred.yml")["channel"]
    @token = cred["LINE_CHANNEL_TOKEN"] 
    @secret = cred["LINE_CHANNEL_SECRET"] 
  end

  def push_message(user_id, message_hash)
    conn = Faraday::Connection.new(url: 'https://api.line.me/v2/bot/message/push') do |builder|
      builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
      builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
      builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
    end

    body = {
      "to": user_id,
      "messages": [message_hash]
    }

    res = conn.post do |req|
      req.headers['Authorization'] = "Bearer #{@token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = body.to_json
    end 
    puts body.to_json

    puts res.body
  end

  

end
