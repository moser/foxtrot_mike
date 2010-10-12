class HeadersController < ApplicationController
  def index
    if params[:for]
      respond_to do |f|
        f.json { render :json => Hash[
          params[:for].singularize.camelize.constantize.all.map { |e| 
            [ e.id, { :title => e.to_s, :line => e.info } ]
          }
        ].to_json }
      end
    end
  end
end
