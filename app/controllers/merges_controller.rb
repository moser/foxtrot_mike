class MergesController < ApplicationController
  def create
    @parent = parent
    @parent.merge_to(@parent.class.find(params[:to_id]))
    redirect_to @parent
  end

private
  def parent
    [ :person, :airfield ].each do |o|
      return o.to_s.camelcase.constantize.find(params["#{o}_id"]) if params["#{o}_id"]
    end
  end
end
