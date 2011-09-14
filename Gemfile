source 'http://rubygems.org'

gem 'rails', '3.1.0'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

# gem 'sqlite3'
gem 'mysql'

# very fast and light server (after problems with mongrel...)
# more: http://code.macournoyer.com/thin/usage/
gem 'thin'

# to make life easier and more pleasant :)
# more: http://aledalgrande.posterous.com/52292198
# haml-rails instead haml is required for generators to make HAML default instead of ERB.
gem 'coffee-filter'
gem 'haml-rails'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development, :test do
  gem 'annotate'
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'shoulda'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end
