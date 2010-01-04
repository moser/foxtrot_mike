class PICAndXCrew < Crew
  belongs_to :pic, :class_name => 'Person'
  belongs_to :co, :class_name => 'Person'
  
  def seat1
    self.pic
  end
  
  def seat1= obj
    self.pic = obj
  end
  
  def seat2
    self.co || self.passengers
  end
  
  def seat2= obj
    if obj.is_a? Person
      self.co = obj
    else
      self.passengers = obj
    end
  end
end
