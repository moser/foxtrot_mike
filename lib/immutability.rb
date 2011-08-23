module Immutability
  module ClassMethods
    def immutable(*methods)
      methods.each do |method|
        class_eval <<-END
          def #{method}_with_immutability=(obj)
            raise ImmutableObjectException unless #{method}.nil? || obj == #{method}
            self.#{method}_without_immutability = obj
          end
          alias_method_chain "#{method}=", :immutability
        END
      end
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end
