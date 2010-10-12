class Leaf
  attr_reader :data

  def initialize(data = nil)
    @data = data
  end

  def current?(path)
    !@data.nil? && !@data[:path].nil? && path =~ /^#{@data[:path]}/
  end
  
  def children
    []
  end
end
