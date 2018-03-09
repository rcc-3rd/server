require 'singleton'
require_relative 'room'


class BeaconAllocator
  include Singleton

  def allocate_event (event) 

    #user_idにuserをセット
    user_id = event["source"]["userId"]

    #beabom_idをroom_idとする
    room_id = event["beacon"]["hwid"]

    user = User.find_by(line_id: user_id)

    unless user
      puts "unknown user"
      return Error.new("unknown user") 
    end

    send_ad(user_id)
    if $line_allocator.rooms.any? {|w| w.room_id == room_id} then
      #roomが存在した場合
      join_room(room_id, user_id)
      participants_list = get_users(room_id)
      send_participants_list(user_id, participants_list)
    else
      #roomが存在しない場合
      create_room(room_id, user_id)
      #join_room(room_id, user_id)
      #participants_list = [user_id]
      #send_participants_list(user_id, participants_list)
    end
  end

  def send_ad(user_id)
    hash = $templates.image_post.clone
    hash["originalContentUrl"] = "https://bus.hile.work/img/ad_1040.jpg"
    hash["previewImageUrl"] = "https://bus.hile.work/img/ad_240.jpg"

    $message_helper.push_message(user_id, hash)
  end

  def create_room(room_id,user_id)
    $line_allocator.rooms << Room.new(room_id,user_id)
  end

  def join_room(room_id,user_id)
    room = $line_allocator.rooms.find{|tmp| tmp.room_id == room_id }
    room.users << user_id
  end

  def get_users(room_id)
    participant_list = $line_allocator.rooms.find{|tmp| tmp.room_id == room_id }.users
  end

  def send_participants_list(user_id,participants_list)
    participants_list = participants_list.clone
    participants_list.delete user_id
    participants_list.each do |user| 
      user = User.find_by(line_id: user)

      hash = $templates.beacon_enter_user.clone
      hash["template"]["thumbnailImageUrl"] = "https://bus.hile.work/img/steeve.jpg"
      hash["template"]["title"] = user.name
      hash["template"]["text"] = user.profile
      hash["template"]["actions"][0]["displayText"] = "#{user.name}と話す"
 
      hash["template"]["actions"][0]["data"] = {
        "type": "invite",
        "user_id": user.line_id
      }.to_json

      $message_helper.push_message(user_id, hash)
    end

  end
end

