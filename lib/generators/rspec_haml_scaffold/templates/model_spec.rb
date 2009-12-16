require File.dirname(__FILE__) + '/../spec_helper'

describe <%= singular_name.classify %> do
  before(:each) do
    @<%= file_name %> = <%= singular_name.classify %>.new
  end

  it "should be valid" do
    @<%= file_name %>.should be_valid
  end
end
