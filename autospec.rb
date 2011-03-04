require "open3"

def build_mtimes_hash(globs)
  files = {}
  globs.each { |g|
    Dir[g].each { |file| files[file] = File.mtime(file) }
  }
  files
end

def specs_for(file)
  @sf[file] ||= @mappings.map { |k, v| 
    m = k.match(file)
    if m
      v.call(m)
    else
      []
    end
  }.flatten.select { |f| File.exists?(f) }
end

@specs = ["spec/**/*_spec.rb"]
@files = build_mtimes_hash(["app/**/*.rb", "app/views/**/*.html.haml", "lib/**/*.rb", @specs].flatten)
@specs = @specs.map { |e| Dir[e] }.flatten

@sf = {}
@mappings = { /^app\/views\/(.*)\/(.*)\.html.haml$/ => 
              lambda { |m| ["spec/views/big_fucking_view_spec.rb", "spec/views/#{m[1]}/#{m[2]}.html.haml_spec.rb"] },
             /^app\/(.*)\/(.*)\.rb$/ =>
              lambda { |m| "spec/#{m[1]}/#{m[2]}_spec.rb" },
             /^spec\/(.*)_spec.rb$/ => lambda { |m| "spec/#{m[1]}_spec.rb" },
             /^lib\/launch_accounting_entries.rb$/ => lambda { |m| ["spec/models/tow_flight_spec.rb", "spec/models/wire_launch_spec.rb"] } }
@run_all = true
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
  changed_files = @files.find_all { |file, last_changed|
    begin
      m = File.mtime(file) 
      r = m > last_changed
      @files[file] = m
      r
    rescue Errno::ENOENT => e # file may have been moved, deleted etc. while running rstakeout
      warn e
    end
  }.map { |e| e[0] }

  if !changed_files.empty? || @run_all
      notified = false 
      err = ""
      if @run_all
        c = @specs.join(' ') 
        @run_all = false
      else
        c = changed_files.map { |f| specs_for(f) }.flatten.uniq.join(' ')
      end
      15.times { puts }
      puts "\e[34m##############################################################################\e[0m"
      Open3.popen3("bundle exec rspec --tty #{c}") do |_, stdout, stderr|
        n = 0
        puts "running #{c}"
        while(l = stdout.gets) do
          if l =~ /([0-9]*) examples, 0 failures, ([0-9]*) pending/
            `notify-send '#{$1} example#{$1 == "1" ? "" : "s"}, #{$2} pending' -i ~/code/foxtrot_mike/.notify-img/pending.png &> /dev/null`
            notified = true
            if @run_all_when_green 
              @run_all = true 
              @run_all_when_green = false
            end
          elsif l =~ /([0-9]*) examples*, 0 failures/
            `notify-send '#{$1} example#{$1 == "1" ? "" : "s"} passed' -i ~/code/foxtrot_mike/.notify-img/passed.png &> /dev/null`
            notified = true
            if @run_all_when_green 
              @run_all = true 
              @run_all_when_green = false
            end
          elsif l =~ /([0-9]*) examples*, ([0-9]*) failures*/
            `notify-send '#{$1} example#{$1 == "1" ? "" : "s"}, #{$2} failed' -i ~/code/foxtrot_mike/.notify-img/failed.png &> /dev/null`
            notified = true
            @run_all_when_green = true
          end
          puts l
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

