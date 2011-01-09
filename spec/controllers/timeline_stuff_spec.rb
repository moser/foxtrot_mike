require File.dirname(__FILE__) + '/../spec_helper'

describe "TimelineStuff" do

  class TheController < ApplicationController
    include TimelineStuff
    attr_reader :scope, :zoom_in, :zoom_out, :base, :groups, :first_group, :next_base, :prev_base, :from, :to
  end

  before(:each) do
    @instance = TheController.new
  end

  describe "setup_scope" do
    it "should set a default scope" do
      @instance.setup_scope(nil)
      @instance.scope.should == "day"
    end
    
    it "should set scopes from zoom_in and zoom_out" do
      @instance.setup_scope(nil)
      @instance.zoom_in.should be_nil
      @instance.zoom_out.should == "week"

      @instance.setup_scope("week")
      @instance.zoom_in.should == "day"
      @instance.zoom_out.should == "month"
    end
  end

  describe "setup_groups" do
    before(:each) do
      @instance.setup_scope(nil)
    end

    it "should parse the current_base" do
      @instance.setup_groups("2010-01-01")
      @instance.base.should == Date.parse("2010-01-01")
    end

    it "should set a default for base" do
      @instance.setup_groups(nil)
      @instance.base.should == Date.today
    end
    
    it "should create 15 groups" do
      @instance.setup_groups(nil)
      @instance.groups.count.should == 15
    end
    
    it "should create dates as groups" do
      @instance.setup_scope("week")
      @instance.setup_groups(nil)
      @instance.groups.each { |g| g.should be_a(Date) }
    end
  
    it "should create weeks" do
      @instance.setup_scope("week")
      @instance.setup_groups(nil)
      arr = []
      14.times do |i|
        arr[i] = @instance.groups[i+1] - @instance.groups[i]
      end
      arr.each { |d| d.should == Rational(7,1) }
    end
    
    it "should set first_group" do
      @instance.setup_groups(nil)
      @instance.first_group.should < @instance.groups[0]
    end

    it "should set next and prev base" do
      @instance.setup_groups(nil)
      @instance.next_base.should > @instance.groups.last
      @instance.prev_base.should < @instance.groups.last
    end
  end

  describe "setup_range" do
    before(:each) do
      @instance.setup_scope(nil)
      @instance.setup_groups('2010-01-05')
    end
    
    it "should set defaults for from and to" do
      @instance.setup_range(nil, nil)
      @instance.from.should_not be_nil
      @instance.to.should_not be_nil
    end

    it "should parse from and to" do
      @instance.setup_range('2010-01-02', '2009-12-31')
      @instance.from.should be_a(Date)
      @instance.to.should be_a(Date)
    end
    
    it "should swap from and to if ordered wrongly" do
      @instance.setup_range('2010-01-02', '2009-12-31')
      @instance.from.should < @instance.to
    end
    
    it "should adjust the base" do
      @instance.setup_groups('2010-01-17')
      @instance.setup_range('2010-01-01', '2010-01-10')
      @instance.base.should == Date.parse('2010-01-16')
    end
  end

  describe "timeline_locals" do
    before(:each) do
      @instance.setup_scope(nil)
      @instance.setup_groups(nil)
      @instance.setup_range(nil, nil)
    end

    it "should inlude the given url object" do
      @instance.timeline_locals(1)[:url_obj].should == 1
    end
  end

end
