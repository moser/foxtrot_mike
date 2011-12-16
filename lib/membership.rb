module Membership
  module ClassMethods
    def membership(association)
      has_many_current(association)
      association = association.to_s
      own_name = association.gsub("_memberships", "")
      other_name = association.singularize.camelize.constantize.
                      reflect_on_all_associations.
                      select { |a| a.macro == :belongs_to }.
                      reject { |a| a.name == own_name.to_sym }.first.name.to_s

      class_eval <<-END
        def #{other_name.pluralize}
          #{association}.map { |e| e.#{other_name} }
        end

        def current_#{other_name.pluralize}
          current_#{association}.map { |e| e.#{other_name} }
        end

        def #{other_name.pluralize}_at(time)
          #{association}_at(time).map { |e| e.#{other_name} }
        end
      END
    end
  end
  def self.included(base)
    #base.include(Current)
    base.class_eval 'include Current'
    base.extend(ClassMethods)
  end
end
