class PersonCostCategoriesController < ApplicationController

  def index
    @person_cost_categories = PersonCostCategory.find(:all)

    respond_to do |format|
      format.html # index.haml
      format.json  { render :json => @person_cost_categories }
    end
  end

  def show
    @person_cost_category = PersonCostCategory.find(params[:id])

    respond_to do |format|
      format.html # show.haml
      format.json  { render :json => @person_cost_category }
    end
  end
  
  def new
    @person_cost_category = PersonCostCategory.new

    respond_to do |format|
      format.html # new.haml
      format.json  { render :json => @person_cost_category }
    end
  end

  def edit
    @person_cost_category = PersonCostCategory.find(params[:id])
  end

  def create
    @person_cost_category = PersonCostCategory.new(params[:person_cost_category])

    respond_to do |format|
      if @person_cost_category.save
        format.html { redirect_to(person_cost_category_path(@person_cost_category)) }
        format.json  { render :json => @person_cost_category, :status => :created, :location => @person_cost_category }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @person_cost_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @person_cost_category = PersonCostCategory.find(params[:id])

    respond_to do |format|
      if @person_cost_category.update_attributes(params[:person_cost_category])
        format.html { redirect_to(person_cost_category_path(@person_cost_category)) }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @person_cost_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @person_cost_category = PersonCostCategory.find(params[:id])
    @person_cost_category.destroy

    respond_to do |format|
      format.html { redirect_to(person_cost_categories_url) }
      format.json  { head :ok }
    end
  end
end
