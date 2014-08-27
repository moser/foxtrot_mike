class PeopleController < ResourceWithDeletedController
  nested :group

  def status_list
    people = Person.where(member: true).all
    respond_to do |f|
      f.csv do
        csv = CSV.generate(encoding: 'UTF-8', col_sep: "\t") do |csv|
          csv << %w(name account status lvb categories)
          people.each do |person|
            csv << [person.name,
                    person.financial_account.try(:number),
                    I18n.t("person.member_state.#{person.member_state}"),
                    I18n.t("person.lvb_member_state.#{person.lvb_member_state}"),
                    ] + person.current_person_cost_category_memberships.map(&:person_cost_category).map(&:name)
          end
        end
        render text: csv
      end
    end
  end
end
