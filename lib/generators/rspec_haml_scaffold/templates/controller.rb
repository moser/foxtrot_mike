class <%= controller_class_name %>Controller < ApplicationController

  def index
    @<%= plural_name %> = <%= singular_name.classify %>.find(:all)

    respond_to do |format|
      format.html # index.haml
      format.json  { render :json => @<%= plural_name %> }
    end
  end

  def show
    @<%= singular_name %> = <%= singular_name.classify %>.find(params[:id])

    respond_to do |format|
      format.html # show.haml
      format.json  { render :json => @<%= singular_name %> }
    end
  end
  
  def new
    @<%= singular_name %> = <%= singular_name.classify %>.new

    respond_to do |format|
      format.html # new.haml
      format.json  { render :json => @<%= singular_name %> }
    end
  end

  def edit
    @<%= singular_name %> = <%= singular_name.classify %>.find(params[:id])
  end

  def create
    @<%= file_name %> = <%= singular_name.classify %>.new(params[:<%= singular_name %>])

    respond_to do |format|
      if @<%= file_name %>.save
        format.html { redirect_to(<%= table_name.singularize %>_path(@<%= file_name %>)) }
        format.json  { render :json => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @<%= file_name %> = <%= singular_name.classify %>.find(params[:id])

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        format.html { redirect_to(<%= table_name.singularize %>_path(@<%= file_name %>)) }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @<%= file_name %> = <%= singular_name.classify %>.find(params[:id])
    @<%= file_name %>.destroy

    respond_to do |format|
      format.html { redirect_to(<%= table_name %>_url) }
      format.json  { head :ok }
    end
  end
end
