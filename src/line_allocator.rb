require 'singleton'


class LineAllocator
  include Singleton

  attr_accessor :rooms

  #Redis使う
  def initialize
    @rooms = []
    @image_map = {
      "右上": "right_up", "右中": "right_mid", "右下": "right_down",
      "左上": "left_up", "左中": "left_mid", "左下": "left_down"
    }
  end

  def allocate_message(event) 
    user_id = event['source']['userId']

    room = find_room_by_user(user_id)
    return false

    partner = room.pairs[user_id] 
    return false
   
    text = event['message']['text']

    # リッチメニュー系の処理
    # せめてpostとかにできないか
    if(text == "Finish")
      room.pairs.delete(user_id)
      room.pairs.delete(partner)

      room.users.delete(user_id)
      room.users.delete(partner)

      msg = {
        "type": "text",
        "text": "お話タイムは終了です！"
      }

      $line_client.push_message(user_id, msg)
      $line_client.push_message(partner, msg)

    elsif (text == "Meet")
      hash = $templates.tell_position_imagemap
      hash['baseUrl'] = 'https://bus.hile.work/img/bus_image'

      $line_client.push_message(user_id, hash)

    elsif (text.start_with? "バスの")
      file = "https://bus.hile.work/img/#{@image_map[text[3..-1].to_sym]}"
      hash = $templates.image_post
      hash['originalContentUrl'] = "#{file}_1040.png"
      hash['previewImageUrl'] = "#{file}_240.png"

      $line_client.push_message(partner, hash)

      sign = $templates.image_post
      sign['originalContentUrl'] = 'https://bus.hile.work/img/sign1040.jpg'
      sign['previewImageUrl'] = 'https://bus.hile.work/img/sign240.jpg'

      $line_client.push_message(partner, sign)

    else
      msg = {
        "type": "text",
        "text": text
      }

      $line_client.push_message(partner, msg)
    end
  
    return true
  end


  def allocate_postback event
    params = parse_json event['postback']['data']
    return false unless params

    sender = event['source']['userId']

    case params['type']
    when 'invite'
      puts "get invite"
      send_invite sender, params['user_id']

    when 'matching'
      puts "get matching"
      pairing sender, params['user_id']

    else
      puts "invalid postback type"
      return false

    end

    return true
  end

  def find_room_by_user user_id 
    room = @rooms.find{|r| r.users.include? user_id}

  end


  # ペアリングを設定
  def pairing(user_id, target_id)
    room = find_room_by_user user_id
    room.pairing(user_id, target_id)

    room = find_room_by_user target_id
    room.pairing(user_id, target_id)
    
    msg = {
      "type": "text",
      "text": "#{User.find_by(line_id: target_id).name}と話しています"
    }
    $line_client.push_message(user_id, msg)

    msg['text'] = "#{User.find_by(line_id: user_id).name}と話しています"
    $line_client.push_message(target_id, msg)
  end

  # registerメッセージ
  def send_register(user_id)
    message = $templates.first_register
    message['text'] += user_id
    puts message.to_json

    res = $line_client.push_message(user_id, message)
  end

  # validateしてから読んでねてへぺろ
  def register_user(params)
    user = User.find_by(line_id: params[:line_id])

    user = User.create(params) unless user
  end

  def send_invite(user_id, target_id)
    # matching用の招待を送信
    hash = $templates.invite
    tmp = hash['template']

    user = User.find_by(line_id: user_id)
    tmp['title'] = "#{user.name}からのお誘い"
    tmp['text'] = user.profile
    # TODO: サムネから取ってくる
    tmp['thumbnailImageUrl'] = "https://bus.hile.work/img/steeve.jpg"
    tmp['actions'][0]['data'] = {
      "type": "matching",
      "user_id": user_id
    }.to_json

    $line_client.push_message target_id, hash
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


end
