class PlaneCostCategoriesController < ApplicationController

  def index
    @plane_cost_categories = PlaneCostCategory.find(:all)

    respond_to do |format|
      format.html # index.haml
      format.json  { render :json => @plane_cost_categories }
    end
  end

  def show
    @plane_cost_category = PlaneCostCategory.find(params[:id])

    respond_to do |format|
      format.html # show.haml
      format.json  { render :json => @plane_cost_category }
    end
  end
  
  def new
    @plane_cost_category = PlaneCostCategory.new

    respond_to do |format|
      format.html # new.haml
      format.json  { render :json => @plane_cost_category }
    end
  end

  def edit
    @plane_cost_category = PlaneCostCategory.find(params[:id])
  end

  def create
    @plane_cost_category = PlaneCostCategory.new(params[:plane_cost_category])

    respond_to do |format|
      if @plane_cost_category.save
        format.html { redirect_to(plane_cost_category_path(@plane_cost_category)) }
        format.json  { render :json => @plane_cost_category, :status => :created, :location => @plane_cost_category }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @plane_cost_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @plane_cost_category = PlaneCostCategory.find(params[:id])

    respond_to do |format|
      if @plane_cost_category.update_attributes(params[:plane_cost_category])
        format.html { redirect_to(plane_cost_category_path(@plane_cost_category)) }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @plane_cost_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @plane_cost_category = PlaneCostCategory.find(params[:id])
    @plane_cost_category.destroy

    respond_to do |format|
      format.html { redirect_to(plane_cost_categories_url) }
      format.json  { head :ok }
    end
  end
end
