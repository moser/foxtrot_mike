class AirfieldsController < ApplicationController

  def index
    @airfields = Airfield.find(:all)

    respond_to do |format|
      format.html # index.haml
      format.json  { render :json => @airfields }
    end
  end

  def show
    @airfield = Airfield.find(params[:id])

    respond_to do |format|
      format.html # show.haml
      format.json  { render :json => @airfield }
    end
  end
  
  def new
    @airfield = Airfield.new

    respond_to do |format|
      format.html # new.haml
      format.json  { render :json => @airfield }
    end
  end

  def edit
    @airfield = Airfield.find(params[:id])
  end

  def create
    @airfield = Airfield.new(params[:airfield])

    respond_to do |format|
      if @airfield.save
        format.html { redirect_to(airfield_path(@airfield)) }
        format.json  { render :json => @airfield, :status => :created, :location => @airfield }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @airfield.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @airfield = Airfield.find(params[:id])

    respond_to do |format|
      if @airfield.update_attributes(params[:airfield])
        format.html { redirect_to(airfield_path(@airfield)) }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @airfield.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @airfield = Airfield.find(params[:id])
    @airfield.destroy

    respond_to do |format|
      format.html { redirect_to(airfields_url) }
      format.json  { head :ok }
    end
  end
end
