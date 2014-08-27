class ResourceWithDeletedController < ResourceController
  def model_all_or_after(conditions = nil, order = nil)
    if params['deleted'] == 'false'
      super({deleted: false}, order)
    else
      super(conditions, order)
    end
  end
end
