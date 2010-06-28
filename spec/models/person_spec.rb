require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Person do  
  it "should find people by their name" do
    martin = Person.generate!(:lastname => "Foo", :firstname => "Martin")
    tom = Person.generate!(:lastname => "Foo", :firstname => "Tom")
    Person.find_by_name('foo').should == nil
    Person.find_by_name('martin').should == martin
    Person.find_by_name('martin f').should == martin
    Person.find_by_name('FOO M').should == martin
  end
  
  it "should find all people by their name" do
    martin = Person.generate!(:lastname => "Foo", :firstname => "Martin")
    tom = Person.generate!(:lastname => "Foo", :firstname => "Tom")
    Person.find_all_by_name('foo').should == [martin, tom]
    Person.find_all_by_name('martin').should == [martin]
    Person.find_all_by_name('martin f').should == [martin]
    Person.find_all_by_name('FOO M').should == [martin]
  end
  
  it "should have many person cost category memberships" do
    r = Person.reflect_on_association :person_cost_category_memberships
    r.class_name.should == "PersonCostCategoryMembership"
    r.macro.should == :has_many
  end
  
  it "should be revisable" do
    Person.new.should respond_to :versions
  end
end
