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

  it "should return a hash for to_j" do
    pc = LegalPlaneClass.create :name => "bar"
    l = License.generate! :name => "foo", :legal_plane_classes => [pc], :level => "normal", :valid_from => 1.day.ago, :valid_to => 1.day.from_now
    l.reload
    l.to_j.should == { :name => "foo", :level => "normal", :legal_plane_class_ids => [pc.id], :valid_from => 1.day.ago.to_date, :valid_to => 1.day.from_now.to_date }
  end
end
