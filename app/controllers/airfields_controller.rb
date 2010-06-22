class AirfieldsController < ApplicationController
  #prepend_before_filter :login_required

  def index
    if @after.nil?
      @airfields = Airfield.find(:all)
    else
      @airfields = Airfield.find(:all, :conditions => ['updated_at > ?', @after] )
    end 
    
    respond_to do |format|
      format.html # index.haml
      format.json  { render :json => @airfields.to_json(:only => Airfield.shared_attribute_names) }
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
    @airfield.id = params[:airfield][:id] unless params[:airfield].nil? || params[:airfield][:id].nil?
    
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
