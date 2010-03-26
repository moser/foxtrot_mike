class GraveyardController < ApplicationController
  #before_filter :login_required
  
  def method_missing(key, *args)
    serve_for = [ "planes", "people", "airfields" ]
    key = key.to_s
    unless serve_for.include? key
      @ids = []
    else
      @ids = "#{key.singularize}_revision".camelize.constantize.find(:all, :conditions => ["revisable_deleted_at > ?", @after_date || 0]).map { |r| r.id }
    end
    respond_to do |format|
      format.html { render :text => @ids.join(',') }
      format.json { render :json => @ids }
    end
  end
end
=begin
, "time_cost_rules", "tow_cost_rules",
                  "wire_launch_cost_rules", "person_cost_categories", "plane_cost_categories",
                  "wire_launcher_cost_categories"
=end
