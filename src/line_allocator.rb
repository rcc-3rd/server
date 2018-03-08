require 'singleton'


class LineAllocator
  include Singleton

  attr_accessor :rooms

  #Redis使う
  def initialize
    @rooms = []
  end

  def allocate_event (user_id, event) 
    room = find_room_by_user(user_id)
    return Error.new("not in room") unless room

    partner = room.pairs[user_id] 
    return Error.new("yet paired") unless partner
   
    msg = {
      "type": "text",
      "text": event["message"]["text"] 
    }

    $message_helper.push_message(partner, msg)
  
    return Success.new("success")
  end

  def find_room_by_user user_id 
    room = @rooms.find{|r| r.users.include? user_id}

  end


  # ペアリングを設定
  def pairing(user_id, target_id)
    room = find_room_by_user user_id
    room.pairing(user_id, target_id)
    
    msg = {
      "type": "text",
      "text": "#{User.find_by(line_id: target_id).name}と話しています"
    }
    
    $message_helper.push_message(user_id, msg)

    msg["text"] = "#{User.find_by(line_id: user_id).name}と話しています"
    $message_helper.push_message(target_id, msg)

    return Success.new("pairing done")
  end

  # registerメッセージ
  def send_register(user_id)
    message = $templates.first_register.clone
    message["text"] += user_id
    puts message.to_json

    res = $message_helper.push_message(user_id, message)
  end

  # validateしてから読んでねてへぺろ
  def register_user(params)
    params["active"] = 1
    user = User.find_by(line_id: params[:line_id])

    user = User.create(params) unless user
  end

  def send_invite(user_id, target_id)
    # matching用の招待を送信
    hash = $templates.invite.clone
    tmp = hash["template"]

    user = User.find_by(line_id: user_id)
    tmp["title"] = "#{user.name}からのお誘い"
    tmp["text"] = user.profile
    tmp["thumbnailImageUrl"] = "https://bus.hile.work/img/steeve.jpg"
    tmp["actions"][0]["data"] = {
      "type": "matching",
      "user_id": user_id
    }.to_json

    $message_helper.push_message target_id, hash

  end

end
