require 'singleton'


class LineAllocator
  include Singleton

  #Redis使う
  @@rooms = []

  def allocate_event (event) 
    # roomを
    
    
    
  
    return Success.new("success")
  end


  # ペアリングを設定
  def pairing(user_id, target_id)

    return Success.new("pairing done")
  end

  # registerメッセージ
  def send_register(user_id)
    message = $templates.first_register.clone
    message["text"] += user_id

    $line_client.push_message(user_id, message.to_json)
  end

# validateしてから読んでねてへぺろ
  def register_user(params)
    params["active"] = 1

    user = User.create(params)
  end

  def send_invite(user_id, target_id)
    # matching用の招待を送信

  end



end
