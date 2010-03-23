class GraveyardController < ApplicationController
  # 
  def method_missing(key, *args)
    serve_for = [ "planes", "people", "airfields" ]
    key = key.to_s
    raise NoMethodError unless serve_for.include? key
    @ids = "#{key.singularize}_revision".camelize.constantize.find(:all, :conditions => ["revisable_deleted_at > ?", @after_date || 0]).map { |r| r.id }
    respond_to do |format|
      format.html { render :text => @ids.join(',') }
      format.json { render :json => @ids }
    end
  end
end
