class EnsureImmutabilityOf
  def initialize(field, value = nil)
    @field = field
    @value = value
  end
  
  def value
    (@value.respond_to?(:call) && @value.call) || @value || @field.to_s.camelize.constantize.generate!
  end
  
  def matches?(model)
    @ematcher = RSpec::Matchers::BuiltIn::RaiseError.new
    unless @ematcher.matches?(lambda { model.send("#{@field}=", value) })
      @ematcher = RSpec::Matchers::BuiltIn::RaiseError.new(ImmutableObjectException)
      if @ematcher.matches?(lambda { model.send("#{@field}=", value) })
        @ematcher.matches?(lambda { model.update_attributes @field => value })
      end
    end
  end
  
  def failure_message
    @ematcher.failure_message
  end
end

def ensure_immutability_of(field, value = nil)
  EnsureImmutabilityOf.new(field, value)
end
