module SoftValidation
  class Validator
    attr_reader :proc
    attr_reader :severity
    attr_accessor :to_s
    
    def initialize(severity, proc)
      @severity = severity
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
  
    #
    #
    def soft_validate(severity_threshold = 0)
      @problems = {}
      self.class.soft_validations.each do |v| 
        v.validate(self) if v.severity >= severity_threshold
      end
      @problems.size == 0
    end
  
    module ClassMethods      
      def soft_validate(severity, &block)
        @soft_validations ||= []
        @soft_validations << SoftValidation::Validator.new(severity, block)
      end
      
      def soft_validates_presence_of(severity, col)
        soft_validate(severity) do |r|
          r.problems[col] = "is needed" if r.send(col).nil?
        end
      end
      
      def soft_validations
        @soft_validations ||= []
      end
    end
  end
end


