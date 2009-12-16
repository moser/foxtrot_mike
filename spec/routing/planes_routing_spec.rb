require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PlanesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "planes", :action => "index").should == "/planes"
    end

    it "maps #new" do
      route_for(:controller => "planes", :action => "new").should == "/planes/new"
    end

    it "maps #show" do
      route_for(:controller => "planes", :action => "show", :id => "1").should == "/planes/1"
    end

    it "maps #edit" do
      route_for(:controller => "planes", :action => "edit", :id => "1").should == "/planes/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "planes", :action => "create").should == {:path => "/planes", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "planes", :action => "update", :id => "1").should == {:path =>"/planes/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "planes", :action => "destroy", :id => "1").should == {:path =>"/planes/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/planes").should == {:controller => "planes", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/planes/new").should == {:controller => "planes", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/planes").should == {:controller => "planes", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/planes/1").should == {:controller => "planes", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/planes/1/edit").should == {:controller => "planes", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/planes/1").should == {:controller => "planes", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/planes/1").should == {:controller => "planes", :action => "destroy", :id => "1"}
    end
  end
end
