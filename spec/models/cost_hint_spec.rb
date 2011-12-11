require "spec_helper"

describe CostHint do
  describe "#to_j" do
    it "should include id and name" do
      CostHint.new.to_j.keys.should == [ :id, :name ]
    end
  end
end
