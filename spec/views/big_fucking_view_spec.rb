require File.dirname(__FILE__) + '/../spec_helper'

# View specs only setup the necessary variables and check if views render
# There are some special views which are speced in their own files (e.g. flights/index)

fourTemplates = [ :accounts, :airfields, :financial_accounts, :groups, :people,
                  :person_cost_categories, :person_cost_category_memberships, 
                  :plane_cost_categories, :plane_cost_category_memberships, :planes,
                  :wire_launcher_cost_categories,
                  :wire_launcher_cost_category_memberships, :wire_launchers ]
nested = { :person_cost_category_memberships => "Person", :plane_cost_category_memberships => "Plane", :wire_launcher_cost_category_memberships => "WireLauncher" }

specs = { :flights => [ :show, :edit, :new ], :time_cost_rules => [ :show, :edit, :new ], :wire_launch_cost_rules => [ :show, :edit, :new ] }
fourTemplates.each do |c|
  specs[c] = [ :edit, :index, :new, :show ]
end

specs.each do |c, as| 
  c = c.to_s
  as = [as].flatten.map(&:to_s)
  as.each do |a|                  
    describe "/#{c}/#{a}.html.haml" do
      before do
        if a == "index"
          eval "assigns[:#{c}] = @#{c} = [#{c.singularize.camelcase}.generate!, #{c.singularize.camelcase}.generate!]"
          eval "assigns[:nested] = @nested = #{nested[c.to_sym]}.generate!" if nested[c.to_sym]
        elsif a == "new"
          eval "assigns[:#{c.singularize}] = @#{c.singularize} = #{c.singularize.camelcase}.new"
        else
          eval "assigns[:#{c.singularize}] = @#{c.singularize} = #{c.singularize.camelcase}.generate!"
        end
      end

      it "should render" do
        render
      end
    end
  end
end
