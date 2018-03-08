
class Room
  attr_accessor :users, :room_id, :pairs
  
  def initialize(room_id, user)
    @users = []
    @pairs = {}

    @room_id = room_id
    @users << user
    
  end

  def pairing(user, target)
    @pairs[user] = target
    @pairs[target] = user
    
  end

end
