require "spec_helper"

describe CostHint do
  describe "#to_j" do
    it "should include id and name" do
      CostHint.new(name: 'Foo').to_j.keys.should == [ :id, :name, :short ]
    end
  end
end
