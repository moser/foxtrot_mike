require 'spec_helper'

describe License do
  it { should belong_to :person }
  it { should have_and_belong_to_many :legal_plane_classes }

  it "should be sortable" do
    License.new.should respond_to :'<=>'
    a = License.new(:name => "GPL")
    b = License.new(:name => "JAR FCL")
    c = License.new(:name => "ZZZZ")
    [b, c, a].sort.should == [a, b, c]
  end
end
