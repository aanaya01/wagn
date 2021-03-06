# -*- encoding : utf-8 -*-

class Card
  class Error < StandardError #code problem
  end
  
  class Oops < Error # wagneer problem
  end
  
  class BadQuery < Error
  end
    
  class PermissionDenied < Error
    attr_reader :card
  
    def initialize card
      @card = card
      super build_message
    end

    def build_message
      if msg = @card.errors[:permission_denied]
        "for card #{@card.name}: #{msg}"
      else
        super
      end
    end
  end
  
  class Abort < Exception
    attr_reader :status

    def initialize status=:failure, msg=''
      @status = status
      super msg
    end

  end
end
