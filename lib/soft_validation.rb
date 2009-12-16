module SoftValidation
  class Validator
    attr_reader :proc
    attr_accessor :to_s
    
    def initialize(proc)
      @proc = proc
    end
    
    def validate(record)
      proc.call record
    end
  end
  
  module Validation
    def self.included(base) #:nodoc:
      base.extend ClassMethods
    end
    
    attr_reader :problems
  
    def soft_validate
      @problems = {}
      self.class.soft_validations.each do |v|
        v.validate(self)
      end
      @problems.size == 0
    end
  
    module ClassMethods      
      def soft_validate(&block)
        @soft_validations ||= []
        @soft_validations << SoftValidation::Validator.new(block)
      end
      
      def soft_validates_presence_of(col)
        soft_validate do |r|
          r.problems[col] = "is needed" if r.send(col).nil?
        end
      end
      
      def soft_validations
        @soft_validations ||= []
      end
    end
  end
end


