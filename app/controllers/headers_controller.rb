class HeadersController < ApplicationController
  def index
    if params[:for]
      elements = Hash[
          params[:for].singularize.camelize.constantize.all.map { |e| 
            [ e.id, { :title => e.to_s, :line => e.info } ]
          } ]
      elements["unknown"] = { :title => I18n.t("unknown_person"), :line => "" } if params[:for] == "people"
      respond_to do |f|
        f.json { render :json => elements.to_json }
      end
    end
  end
end
