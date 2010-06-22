class PlanesController < ApplicationController
  #prepend_before_filter :login_required
  
  # GET /planes
  # GET /planes.xml
  def index
    if @after.nil?
      @planes = Plane.all
    else
      @planes = Plane.find(:all, :conditions => ['updated_at > ?', @after] )
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @planes.to_json(:only => Plane.shared_attribute_names) }
    end
  end

  # GET /planes/1
  # GET /planes/1.xml
  def show
    @plane = Plane.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @plane }
    end
  end

  # GET /planes/new
  # GET /planes/new.xml
  def new
    @plane = Plane.new

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @plane }
    end
  end

  # GET /planes/1/edit
  def edit
    @plane = Plane.find(params[:id])
  end

  # POST /planes
  # POST /planes.xml
  def create
    @plane = Plane.new(params[:plane])
    @plane.id = params[:plane][:id] unless params[:plane].nil? || params[:plane][:id].nil?
    
    respond_to do |format|
      if @plane.save
        flash[:notice] = 'Plane was successfully created.'
        format.html { redirect_to(@plane) }
        format.json  { render :json => @plane, :status => :created, :location => @plane }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @plane.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /planes/1
  # PUT /planes/1.xml
  def update
    @plane = Plane.find(params[:id])

    respond_to do |format|
      if @plane.update_attributes(params[:plane])
        flash[:notice] = 'Plane was successfully updated.'
        format.html { redirect_to(@plane) }
        format.json  { render :json => @plane, :location => @plane }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @plane.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /planes/1
  # DELETE /planes/1.xml
  def destroy
    @plane = Plane.find(params[:id])
    @plane.destroy

    respond_to do |format|
      format.html { redirect_to(planes_url) }
      format.xml  { head :ok }
    end
  end
end
