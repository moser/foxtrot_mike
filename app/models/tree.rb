class Tree
  attr_reader :children, :data
  
  def initialize(data = nil)
    @data = data
    @children = []
    yield(self) if block_given?
  end

  def current?(path)
    (!@data.nil? && !@data[:path].nil? && @data[:path] == path) || !!(children.find { |c| c.current?(path) })
  end
end
