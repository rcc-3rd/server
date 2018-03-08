require 'singleton'

class BeaconAcceptor
  include Singleton

  def allocate_event (event) 

    #user_idにuserをセット
    user_id = ecent[:user]

    #beabom_idをroom_idとする
    room_id = event[:hwid]
    if line_allocator.rooms.any? {|w| w == room_id} then
      #roomが存在した場合
      join_room(room_id)
      participants_list = get_users(room_id)
    else
      #roomが存在しない場合
      create_room(room_id)
      join_room(room_id)
      participant_list = [user_id]
    end
  end

  def create_room(room_id,user_id)
    rooms << Room.new(room_id,user_id)
  end

  def join_room(room_id,user_id)
    rooms[room_id].users << user_id
  end

  def get_users(room_id)
    return rooms[room_id].users
  end

end

