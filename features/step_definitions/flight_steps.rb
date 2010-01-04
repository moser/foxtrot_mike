Given "there is a flight" do
  Factory.create(:flight)
  Flight.count.should == 1
end

Then "there should be no flights" do
  Flight.count.should == 0
end
