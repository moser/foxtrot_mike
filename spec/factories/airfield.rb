Factory.define :airfield do |a|
  a.sequence(:name) {|n| "Airfield #{n} #{DateTime.now}" }
  a.sequence(:registration) {|n| "#{n} #{DateTime.now}" }
end
