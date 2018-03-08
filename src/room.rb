
class Room
  attr_accessor :users, :room_id
  @users = []
  
  def initialize(room_id, user)
    @room_id = room_id
    @users << user

    
  end


end
