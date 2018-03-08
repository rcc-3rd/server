require 'singleton'


class BeaconAllocator
  include Singleton

  def allocate_event (event) 

    #user_idにuserをセット
    user_id = event["userId"]

    #beabom_idをroom_idとする
    room_id = event["hwid"]

    if $line_allocator.rooms.any? {|w| w.room_id == room_id} then
      #roomが存在した場合
      join_room(room_id, user_id)
      participants_list = get_users(room_id)
      send_participants_list(user_id, participants_list)
    else
      #roomが存在しない場合
      create_room(room_id, user_id)
      join_room(room_id, user_id)
      participant_list = [user_id]
      send_participants_list(user_id, participants_list)
    end
  end

  def create_room(room_id,user_id)
    rooms << Room.new(room_id,user_id)
  end

  def join_room(room_id,user_id)
    room = rooms.find{|tmp| tmp.room_id == room_id }
    room.users << user_id
  end

  def get_users(room_id)
    participant_list = rooms.find{|tmp| tmp.beacon == room_id }.users
    push_message(user_id, message_hash)
  end

  def send_participants_list(user_id,participants_list)
    message_hash = {"type":"text","text": participants_list}
    $message_helper.push_message(user_id, message_hash)
  end

end
