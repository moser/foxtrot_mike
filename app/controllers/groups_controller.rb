class GroupsController < ApplicationController
  #before_filter :login_required
  
  def index
    if @after.nil?
      @groups = Group.find(:all)
    else
      @groups = Group.find(:all, :conditions => ['updated_at > ?', @after] )
    end

    respond_to do |format|
      format.json  { render :json => @groups }
    end
  end
end
