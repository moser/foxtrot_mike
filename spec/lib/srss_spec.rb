require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

Delta = 7.0 / 1440.0 #7 minutes is an acceptable difference to NOAA's values
describe 'SRSS' do
  before(:all) do
    @srss = SRSS.new(49.0, 12.0)
  end
  
  describe "sunrise" do
    it "should be near the values from NOAA" do #http://www.esrl.noaa.gov/gmd/grad/solcalc/
      (@srss.sunrise(Date.new(2011, 1, 1, 0)) - DateTime.new(2011, 1, 1, 7, 6, 0,0)).abs.should < Delta
      (@srss.sunrise(Date.new(2011, 3, 8, 0)) - DateTime.new(2011, 3, 8, 5, 41, 0,0)).abs.should < Delta
      (@srss.sunrise(Date.new(2011, 3, 21, 0)) - DateTime.new(2011, 3, 21, 5, 21, 0,0)).abs.should < Delta
      (@srss.sunrise(Date.new(2011, 6, 21, 0)) - DateTime.new(2011, 6, 21, 3, 8, 0,0)).abs.should < Delta
      (@srss.sunrise(Date.new(2011, 9, 21, 0)) - DateTime.new(2011, 9, 21, 4, 56, 0,0)).abs.should < Delta
      (@srss.sunrise(Date.new(2011, 12, 21, 0)) - DateTime.new(2011, 12, 21, 7, 3, 0,0)).abs.should < Delta
    end
  end
  
  describe "sunset" do
    it "should be near the values from NOAA" do #http://www.esrl.noaa.gov/gmd/grad/solcalc/
      (@srss.sunset(Date.new(2011, 1, 1, 0)) - DateTime.new(2011, 1, 1, 15, 25, 0,0)).abs.should < Delta
      (@srss.sunset(Date.new(2011, 3, 8, 0)) - DateTime.new(2011, 3, 8, 17, 6, 0,0)).abs.should < Delta
      (@srss.sunset(Date.new(2011, 3, 21, 0)) - DateTime.new(2011, 3, 21, 17, 26, 0,0)).abs.should < Delta
      (@srss.sunset(Date.new(2011, 6, 21, 0)) - DateTime.new(2011, 6, 21, 19, 20, 0,0)).abs.should < Delta
      (@srss.sunset(Date.new(2011, 9, 21, 0)) - DateTime.new(2011, 9, 21, 17, 13, 0,0)).abs.should < Delta
      (@srss.sunset(Date.new(2011, 12, 21, 0)) - DateTime.new(2011, 12, 21, 15, 17, 0,0)).abs.should < Delta
    end
  end
end
