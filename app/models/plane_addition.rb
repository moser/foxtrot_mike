module PlaneAddition
  def self.included(base) #:nodoc:
    base.acts_as_revisable :on_delete => :revise
    base.send(:include, TrackEditor)
  end
end
