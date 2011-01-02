Factory.define :group do |g|
  g.sequence(:name) { |n| "Group #{n} #{DateTime.now}" }
end
