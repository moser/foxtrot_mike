source "http://rubygems.org"

gem "rails", "3.1.0.rc6"
gem "rails3-generators"

gem "sass"
gem "coffee-script"
gem "therubyracer"
gem "uglifier"
gem "jquery-rails"

gem "haml"
gem "haml-rails"
gem "uuidtools"
gem "paper_trail"
gem "simple_form", :git => "git://github.com/plataformatec/simple_form.git"
gem "authlogic"
gem "cancan"
gem "fastercsv"
gem "delayed_job"
gem "wicked_pdf"

group :production do
  gem "pg", :require => "pg"
end

group :test do
  gem "rspec"
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "factory_girl"
  gem "webrat"
  gem "rcov"
  gem "capybara", :git => "git://github.com/jnicklas/capybara.git"
  gem "launchy"
  gem "database_cleaner"
end

group :development, :test do
  gem "railroady"
  gem "sqlite3"
end
