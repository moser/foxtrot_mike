require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Person do
  fixtures "people"
  it "should find people by their name" do
    martin = Factory.create(:person, :lastname => "Foo", :firstname => "Martin")
    tom = Factory.create(:person, :lastname => "Foo", :firstname => "Tom")
    Person.find_by_name('foo').should == [martin, tom]
    Person.find_by_name('martin').should == [martin]
    Person.find_by_name('martin f').should == [martin]
    Person.find_by_name('FOO M').should == [martin]
  end
  
  it "should belong to a person cost category" do
    r = Person.reflect_on_association :person_cost_category
    r.class_name.should == "PersonCostCategory"
    r.macro.should == :belongs_to
  end
  
  it "should be revisable" do
    Person.new.should respond_to :revisions
  end
end
