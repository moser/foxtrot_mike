class UnknownPeopleController < ApplicationController
  def show
    respond_to do |format|
      format.json do 
        render :json => UnknownPerson.new.to_j
      end
    end
  end
end
