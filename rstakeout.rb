def build_mtimes_hash(globs)
  files = {}
  globs.each { |g|
    Dir[g].each { |file| files[file] = File.mtime(file) }
  }
  files
end

trap('INT') do
  puts "\nQuitting..."
  exit
end

MYTEMP = ENV['TEMP'] || '/tmp'

files = build_mtimes_hash(ARGV)

js_spec_dir = BlueRidge.find_javascript_spec_dir || (raise error_message_for_missing_spec_dir)

loop do
  changed_file, last_changed = files.find { |file, last_changed|
    begin
      File.mtime(file) > last_changed
    rescue Errno::ENOENT => e # file may have been moved, deleted etc. while running rstakeout
      warn e
    end
  }

  if changed_file
      files[changed_file] = File.mtime(changed_file)
      if BlueRidge.run_specs_in_dir(js_spec_dir, ENV["TEST"])
        `notify-send 'JS specs failed' -i ~/.autotest-img/failed.png`
      else
        `notify-send 'JS specs passed' -i ~/.autotest-img/passed.png`
      end
  end
  sleep 1
end

