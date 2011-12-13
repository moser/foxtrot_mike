require "open3"
require "date"
@mappings = { /^app\/views\/(.*)\/(.*)\.html\.haml$/ => 
              lambda { |m| ["spec/views/big_fucking_view_spec.rb", "spec/views/#{m[1]}/#{m[2]}.html.haml_spec.rb"] },
             /^app\/(.*)\/(.*)\.rb$/ =>
              lambda { |m| "spec/#{m[1]}/#{m[2]}_spec.rb" },
             /^spec\/(.*)_spec\.rb$/ => 
             lambda { |m| "spec/#{m[1]}_spec.rb" },
             /^(lib\/launch_accounting_entries|spec\/models\/shared_examples_for_accounting_entries)\.rb$/ => 
             lambda { |m| ["spec/models/flight_spec.rb", "spec/models/tow_flight_spec.rb", "spec/models/wire_launch_spec.rb"] },
             /^app\/models\/((.*)_cost_category(.*)|plane|wire_launcher|flight|wire_launch|tow_flight|(.*)_cost_rule)\.rb$/ => 
             lambda { |m| ["spec/models/accounting_entry_invalidation_integration_spec.rb"] } }

def build_mtimes_hash(globs, first)
  files = @files || {}
  globs.each { |g|
    Dir[g].each { |file| files[file] = first ? File.mtime(file) : (files[file] || (Time.now - 86400)) }
  }
  files
end

def uncached_specs_for(file)
  @mappings.map { |k, v| 
    m = k.match(file)
    if m
      v.call(m)
    else
      []
    end
  }.flatten.select { |f| File.exists?(f) }
end

def specs_for(file)
  if ((DateTime.now - @file_time) * 1440) > 1 #search for new files every minute
    search_files
    @sf[file] = uncached_specs_for(file)
  end
  @sf[file] ||= uncached_specs_for(file)
end

def search_files(first = false)
  @specs = @spec_dirs.map { |d| Dir[d] }.flatten
  @files = build_mtimes_hash(["app/**/*.rb", "app/views/**/*.html.haml", "lib/**/*.rb", @spec_dirs].flatten, first)
  @file_time = DateTime.now
end

def specs
  if ((DateTime.now - @file_time) * 1440) > 1 #search for new files every minute
    search_files
  end
  @specs
end

def files
  if ((DateTime.now - @file_time) * 1440) > 1 #search for new files every minute
    search_files
  end
  @files
end

@spec_dirs = ["spec/**/*_spec.rb"]
search_files(true)

@sf = {}
@run_all = false
@last_time_all = DateTime.now
@run_all_when_green = false

@int_count = 0

trap('INT') do
  if @int_count == 0
    puts "\nInterrupt again to quit"
    @int_count = 1
    sleep(2)
    @int_count = 0
    @run_all = true
  else
    exit
  end
end

loop do
  changed_files = files.find_all { |file, last_changed|
    begin
      m = File.mtime(file)
      r = m > last_changed
      @files[file] = m
      r
    rescue Errno::ENOENT => e # file may have been moved, deleted etc.
      warn e
      @files.delete file
    end
  }.map { |e| e[0] }

  if !changed_files.empty? || @run_all
      notified = false 
      err = ""
      if @run_all && changed_files.empty? #do not run all, if there are changed files
        c = "bundle exec rake spec"
        @run_all = false
        @last_time_all = DateTime.now
      else
        c = "bundle exec rspec --tty #{changed_files.map { |f| specs_for(f) }.flatten.uniq.join(' ')}"
      end
      15.times { puts }
      puts "\e[34m##############################################################################\e[0m"
      Open3.popen3(c) do |_, stdout, stderr|
        n = 0
        puts "running #{c}"
        l = ""
        while(ch = stdout.getc) do
          putc ch
          if ch == "\n"
            if l =~ /([0-9]*) examples, 0 failures, ([0-9]*) pending/
              `notify-send '#{$1} example#{$1 == "1" ? "" : "s"}, #{$2} pending' -i ~/code/foxtrot_mike/.notify-img/pending.png &> /dev/null`
              notified = true
              if @run_all_when_green 
                #@run_all = true 
                @run_all_when_green = false
              end
            elsif l =~ /([0-9]*) examples*, 0 failures/
              `notify-send '#{$1} example#{$1 == "1" ? "" : "s"} passed' -i ~/code/foxtrot_mike/.notify-img/passed.png &> /dev/null`
              notified = true
              if @run_all_when_green && ((DateTime.now - @last_time_all) * 1440) > 5 #only run all after green every 5 minutes
                #@run_all = true 
                @run_all_when_green = false
              end
            elsif l =~ /([0-9]*) examples*, ([0-9]*) failures*/
              `notify-send '#{$1} example#{$1 == "1" ? "" : "s"}, #{$2} failed' -i ~/code/foxtrot_mike/.notify-img/failed.png &> /dev/null`
              notified = true
              @run_all_when_green = true
            end
            l = ""
          else
            l += ch
          end
        end
        err = stderr.readlines
      end
      unless notified
        `notify-send 'Specs could not be run' -i ~/traffic-light-red.jpg &> /dev/null` 
        puts err
      end  
  else
    sleep 5
  end
end


