module TrackEditor
  def self.included(base) #:nodoc:
    base.belongs_to :editor, :class_name => "Person"
    base.before_save :check_editor
    base.before_destroy :save_editor
  end
  
  def editor=(obj)
    unless obj.nil?
      self.editor_id = obj.id 
    else
      self.editor_id = nil
    end
  end
  
  def editor_id=(i)
    @editor_set = true
    write_attribute(:editor_id, i)
  end

private
  def check_editor
    unless @editor_set
      self.editor = nil
    end
  end
  
  def save_editor
    if @editor_set
      save(false)
    end
  end
end
