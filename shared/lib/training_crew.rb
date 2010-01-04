class TrainingCrew < Crew
  belongs_to :trainee, :class_name => 'Person'
  belongs_to :instructor, :class_name => 'Person'
  
  def seat1
    self.trainee
  end
  
  def seat1= obj
    self.trainee = obj
  end
  
  def seat2
    self.instructor
  end
  
  def seat2= obj
    self.instructor = obj
  end
end
