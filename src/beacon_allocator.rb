require 'singleton'

room_list = ["1","2","3","4","5"]

class BeaconAllocator
  include Singleton

  def allocate_event (event) 
    if room_list.any? {|w| w == event[:hwid]} then
      #Roomが存在した場合
      join_room(event[:hwid])
    else
      #Roomが存在しない場合
      create_room(event[:hwid])
    end

  end



  def join_room(room_id)

  end




  def create_room(room_id)
    room_list.push("#{room_id}")


  end

end

