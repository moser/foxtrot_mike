require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FlightsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "flights", :action => "index").should == "/flights"
    end

    it "maps #new" do
      route_for(:controller => "flights", :action => "new").should == "/flights/new"
    end

    it "maps #show" do
      route_for(:controller => "flights", :action => "show", :id => "1").should == "/flights/1"
    end

    it "maps #edit" do
      route_for(:controller => "flights", :action => "edit", :id => "1").should == "/flights/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "flights", :action => "create").should == {:path => "/flights", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "flights", :action => "update", :id => "1").should == {:path =>"/flights/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "flights", :action => "destroy", :id => "1").should == {:path =>"/flights/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/flights").should == {:controller => "flights", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/flights/new").should == {:controller => "flights", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/flights").should == {:controller => "flights", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/flights/1").should == {:controller => "flights", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/flights/1/edit").should == {:controller => "flights", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/flights/1").should == {:controller => "flights", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/flights/1").should == {:controller => "flights", :action => "destroy", :id => "1"}
    end
  end
end
