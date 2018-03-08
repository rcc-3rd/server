require 'singleton'


class LineAllocator
  include Singleton

  attr_accessor :rooms

  #Redis使う
  def initialize
    @rooms = []
  end

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

  end

end
