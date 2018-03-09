require 'singleton'


class LineAllocator
  include Singleton

  attr_accessor :rooms

  #Redis使う
  def initialize
    @rooms = []
    @map = {
      "右上": "right_up", "右中": "right_mid", "右下": "right_down",
      "左上": "left_up", "左中": "left_mid", "左下": "left_down"
    }
  end

  def allocate_event (user_id, event) 
    room = find_room_by_user(user_id)
    return Error.new("not in room") unless room

    partner = room.pairs[user_id] 
    return Error.new("yet paired") unless partner
   
    text = event["message"]["text"]

    if(text == "Finish")
      room.pairs.delete(user_id)
      room.pairs.delete(partner)

      msg = {
        "type": "text",
        "text": "お話タイムは終了です！"
      }

      $message_helper.push_message(user_id, msg)
      $message_helper.push_message(partner, msg)

    elsif (text == "Meet" && (event["source"]["userId"]==user_id))
      hash = $templates.tell_position_imagemap
      hash["baseUrl"] = "https://bus.hile.work/img/bus_image"

      $message_helper.push_message(user_id, hash)
    elsif (text.start_with? "バスの")
      file = "https://bus.hile.work/img/#{@map[text[3..-1].to_sym]}"
      hash = $templates.image_post.clone
      hash["originalContentUrl"] = "#{file}_1040.png"
      hash["previewImageUrl"] = "#{file}_240.png"

      $message_helper.push_message(partner, hash)

      sign = $templates.image_post.clone
      sign["originalContentUrl"] = "https://bus.hile.work/img/sign1040.jpg"
      sign["previewImageUrl"] = "https://bus.hile.work/img/sign240.jpg"

      $message_helper.push_message(partner, sign)

    else
      msg = {
        "type": "text",
        "text": text
      }

      $message_helper.push_message(partner, msg)
    end
  
    return Success.new("success")
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
    if(user.name == "かいき")
      tmp["thumbnailImageUrl"] = "https://bus.hile.work/img/kaiki.jpg"
    end
    tmp["actions"][0]["data"] = {
      "type": "matching",
      "user_id": user_id
    }.to_json

    $message_helper.push_message target_id, hash

  end

end
