require 'singleton'


class LineAcceptor
  include Singleton

  #Redis使う
  @@rooms = []

  def allocate_event (event) 
    

    
    
    
    return Success.new("success")
  end


end
