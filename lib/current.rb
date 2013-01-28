module Current
  module ClassMethods
    def has_one_current(singular)
      singular = singular.to_s
      association = singular.pluralize
      class_eval <<-END
        def has_one_current_time_of_decision
          AccountingSession.latest_finished_session_end
        end

        def previous_#{association}
          #{association}.where("valid_from < ? OR valid_from IS NULL", has_one_current_time_of_decision).reject { |e| e.valid_at?(has_one_current_time_of_decision) }
        end

        def current_#{singular}
          ##{association}.select { |e| e.valid_at?(has_one_current_time_of_decision) }.first
          #{singular}_at(has_one_current_time_of_decision)
        end

        def future_#{association}
          #{association}.where("valid_from > ?", has_one_current_time_of_decision)
        end

        def #{singular}_at(date)
          #{association}.where("valid_from <= ?", date).order("valid_from DESC").first || #{association}.where(:valid_from => nil).first
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
          if #{association}.respond_to?(:not_valid_anymore_at)
            #{association}.not_valid_anymore_at(Time.now)
          else
            #{association}.select { |e| e.not_valid_anymore_at?(Time.now) }
          end
        end

        def current_#{association}
          if #{association}.respond_to?(:valid_at)
            #{association}.valid_at(Time.now)
          else
            #{association}.select { |e| e.valid_at?(Time.now) }
          end
        end

        def future_#{association}
          if #{association}.respond_to?(:not_yet_valid_at)
            #{association}.not_yet_valid_at(Time.now)
          else
            #{association}.select { |e| e.not_yet_valid_at?(Time.now) }
          end
        end

        def #{association}_at(time)
          if #{association}.respond_to?(:valid_at)
            #{association}.valid_at(time)
          else
            #{association}.select { |e| e.valid_at?(time) }
          end
        end
      END
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end
