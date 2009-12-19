require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../../spec_helper'

describe "/<%= name.pluralize %>/show.<%= default_file_extension %>" do
  include <%= controller_class_name %>Helper
  
  before do
    @<%= file_name %> = mock_model(<%= singular_name.classify %>)
<% for attribute in attributes -%>
    @<%= file_name %>.stub!(:<%= attribute.name %>).and_return(<%= attribute.default_value %>)
<% end -%>

    assigns[:<%= file_name %>] = @<%= file_name %>
  end

  it "should render without erros" do
    render "/<%= name.pluralize %>/show.<%= default_file_extension %>"
  end
end

