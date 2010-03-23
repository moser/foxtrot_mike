require File.expand_path(File.dirname(__FILE__) + '/../../vendor/plugins/blue-ridge/lib/blue_ridge')

def build_mtimes_hash(globs)
  files = {}
  globs.each { |g|
    Dir[g].each { |file| files[file] = File.mtime(file) }
  }
  files
end

desc 'Run js specs whenever a file is changed'
task :autospec_js do
  quit = false
  int = false
  last_int = Time.now - 100
  
  trap('INT') do
    int = true
    quit = (Time.now - last_int) < 5
    last_int = Time.now
  end
  
  files = build_mtimes_hash(['public/javascripts/*.js', 'spec/javascripts/**/*_spec.js', 'spec/javascripts/fixtures/**/*.html'])
  js_spec_dir = BlueRidge.find_javascript_spec_dir || (raise error_message_for_missing_spec_dir)

  while !quit do
    changed_file, last_changed = files.find { |file, last_changed|
      begin
        File.mtime(file) > last_changed
      rescue Errno::ENOENT => e # file may have been moved, deleted etc. while running rstakeout
        warn e
      end
    }

    if changed_file || int
        test = nil
        
        if changed_file
          files[changed_file] = File.mtime(changed_file)
          p changed_file
          m = changed_file.match(/public\/javascripts(\/.*)\.js|spec\/javascripts(\/.*)_spec\.js|spec\/javascripts\/fixtures.*(\/.*)\.html$/)
          if m
            test = m[1] || m[2] || m[3];
            test.gsub!("/", "")
          end
        end
        unless r = BlueRidge.run_specs_in_dir(js_spec_dir, test)
          `notify-send 'JS specs failed' '#{test}' -i ~/.autotest-img/failed.png`
        else
          `notify-send 'JS specs passed' -i ~/.autotest-img/passed.png`
        end
    end
    int = false
    sleep 5
  end
end
