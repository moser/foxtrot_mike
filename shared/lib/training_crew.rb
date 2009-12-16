class TrainingCrew < Crew
  belongs_to :trainee, :class_name => 'Person'
  belongs_to :instructor, :class_name => 'Person'
end
