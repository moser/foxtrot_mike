class PeopleController < ApplicationController

  def index
    @people = Person.find(:all)

    respond_to do |format|
      format.html # index.haml
      format.json  { render :json => @people }
    end
  end

  def show
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html # show.haml
      format.json  { render :json => @person }
    end
  end
  
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.haml
      format.json  { render :json => @person }
    end
  end

  def edit
    @person = Person.find(params[:id])
  end

  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        format.html { redirect_to(person_path(@person)) }
        format.json  { render :json => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to(person_path(@person)) }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(people_url) }
      format.json  { head :ok }
    end
  end
end
