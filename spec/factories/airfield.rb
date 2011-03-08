Factory.define :airfield do |a|
  a.sequence(:name) {|n| "Airfield #{n} #{DateTime.now}" }
  a.sequence(:registration) {|n| "#{n} #{DateTime.now}" }
  a.lat 49.0
  a.long 12.0
end
