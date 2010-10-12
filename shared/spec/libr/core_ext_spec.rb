require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe 'core extensions' do
  describe "Array#group_by" do
    it "should use a set of unique keys" do
      [:aa, 'aa'].group_by(&:to_s).keys.count.should == 1
    end

    it "should group my dates" do
      a = Date.parse("2010-09-01")
      b = Date.parse("2010-10-01")
      [a, b].group_by(&:year).first.should == [2010, [a,b]]
      [a, b].group_by { |d| d.month }.keys.should == [9,10]
    end
  end
end
