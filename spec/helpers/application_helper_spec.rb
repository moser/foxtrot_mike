# encoding: utf-8

require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do

  describe "format_minutes" do
    it "should render - if passed -1 or nil" do
      helper.format_minutes(-1).should == "-"
      helper.format_minutes(nil).should == "-"
    end

    it "should render 0:** if passed i < 60" do
      helper.format_minutes(25).should == "0:25"
    end

    it "should render *:00 if passed i = n*60" do
      helper.format_minutes(0).should == "0:00"
      helper.format_minutes(180).should == "3:00"
    end

    it "should render 0:0* if passed i < 10" do
      helper.format_minutes(5).should == "0:05"
    end
  end

  describe "format_currency" do
    it "should render 0,01 €" do
      helper.format_currency(1).should == "0,01 €"
    end

    it "should render 1,00 €" do
      helper.format_currency(100).should == "1,00 €"
    end

    it "should render 1,01 €" do
      helper.format_currency(101).should == "1,01 €"
    end

    it "should render -1,01 €" do
      helper.format_currency(-101).should == "-1,01 €"
    end

    it "renders -0,01 €" do
      helper.format_currency(-1).should == "-0,01 €"
    end
  end

  describe "scoped_flights_path" do
    let(:person) { F.create(:person) }
    it "returns a path with a /flights appended" do
      helper.scoped_flights_path(person).should == "/people/#{person.id}/flights"
    end

    it "appends query parameters" do
      helper.scoped_flights_path(person, foo: "bar", bar: 1).should == "/people/#{person.id}/flights?bar=1&foo=bar"
    end
  end
end
