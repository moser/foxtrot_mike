class UnknownPerson
  def id
    "unknown"
  end

  def name
    I18n.t("unknown_person")
  end

  def group
    nil
  end

  def person_cost_categories_at(time)
    []
  end

  def person_cost_categories
    []
  end

  def current_person_cost_categories
    []
  end

  def relevant_licenses_for(f)
    []
  end

  def trainee?(f)
    false
  end

  def instructor?(f)
    false
  end

  def to_s
    name
  end

  def to_j
    { :id => id,
      :firstname => name,
      :lastname => "",
      :group_id => nil,
      :group_name => "Lala",
      :licenses => [{:level => "normal", :legal_plane_class_ids => LegalPlaneClass.all.map { |e| e.id }}] }
  end
end
