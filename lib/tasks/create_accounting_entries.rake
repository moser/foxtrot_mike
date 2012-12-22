desc "Create accounting entries for flights with invalid accounting_entries"
task :create_accounting_entries => :environment do |t|
  Flight.where(accounting_entries_valid: false).each do |f|
    puts "Creating accounting entries for flight ##{f.id}"
    f.accounting_entries
  end
end
