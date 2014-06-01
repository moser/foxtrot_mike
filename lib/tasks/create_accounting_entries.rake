desc "Create accounting entries for flights with invalid accounting_entries"
task :create_accounting_entries => :environment do |t|
  AbstractFlight.where(accounting_entries_valid: false).each do |f|
    puts "Creating accounting entries for flight ##{f.id}"
    f.calculate_cost
    f.launch.calculate_cost if f.launch.respond_to?(:calculate_cost)
    f.accounting_entries
  end
end
