module Current
  module ClassMethods
    def has_one_current(singular)
      singular = singular.to_s
      association = singular.pluralize
      class_eval <<-END
        def previous_#{association}
          #{association}.where("valid_from < ? OR valid_from = NULL", Time.now).reject { |e| e.valid_at?(Time.now) }
        end
        
        def current_#{singular}
          #{association}.select { |e| e.valid_at?(Time.now) }.first
        end
        
        def future_#{association}
          #{association}.where("valid_from > ?", Time.now)
        end
        
        def current_#{singular}=(new)
          t = Time.now
          old = current_#{singular}
          old.valid_to = t
          new.valid_from = t
          old.save!
          new.save!
          #{association} << new
        end       
      END
    end

    def has_many_current(association)
      class_eval <<-END
        def previous_#{association}
          #{association}.select { |e| e.not_valid_anymore_at?(Time.now) }
        end

        def current_#{association}
          #{association}.select { |e| e.valid_at?(Time.now) }
        end
        
        def future_#{association}
          #{association}.select { |e| e.not_yet_valid_at?(Time.now) }
        end
        
        def #{association}_at(time)
          #{association}.select { |e| e.valid_at?(time) }
        end
      END
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end
