class MergesController < ApplicationController
  nested :person

  def create
    find_nested
    @nested.merge_to(@nested.class.find(params[:to_id]))
    redirect_to @nested
  end
end
