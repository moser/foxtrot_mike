class PICAndXCrew < Crew
  belongs_to :pic, :class_name => 'Person'
  belongs_to :co, :class_name => 'Person'
end
