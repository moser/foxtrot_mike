class PlanesController < ApplicationController
  # GET /planes
  # GET /planes.xml
  def index
    @planes = Plane.all

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @planes }
    end
  end

  # GET /planes/1
  # GET /planes/1.xml
  def show
    @plane = Plane.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @plane }
    end
  end

  # GET /planes/new
  # GET /planes/new.xml
  def new
    @plane = Plane.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @plane }
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

    respond_to do |format|
      if @plane.save
        flash[:notice] = 'Plane was successfully created.'
        format.html { redirect_to(@plane) }
        format.xml  { render :xml => @plane, :status => :created, :location => @plane }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @plane.errors, :status => :unprocessable_entity }
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
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @plane.errors, :status => :unprocessable_entity }
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
