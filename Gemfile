source 'http://rubygems.org'

gem 'rails'
gem 'rails3-generators'
gem 'sqlite3-ruby', :require => 'sqlite3'

gem "haml"
gem "uuidtools"
gem "paper_trail"
gem "simple_form"
gem "authlogic"
gem "cancan"
gem "fastercsv"
gem "delayed_job"
gem "wicked_pdf"

group :production do
  gem 'pg', :require => 'pg'
end

group :test do
  gem "rspec"
  gem "rspec-rails"
  gem "shoulda"
  gem "factory_girl"
  gem "webrat"
  gem 'remarkable', '>=4.0.0.alpha4'
  gem 'remarkable_activemodel', '>=4.0.0.alpha4'
  gem 'remarkable_activerecord', '>=4.0.0.alpha4'
  gem "jasmine"
  gem "rcov"
end

group :development, :test do
  gem 'railroady'
end
