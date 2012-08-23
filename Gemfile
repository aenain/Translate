source 'http://rubygems.org'

gem 'rails', '~> 3.2.0'
gem 'pg'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'hirb'

# very fast and light server (after problems with mongrel...)
# more: http://code.macournoyer.com/thin/usage/
gem 'thin'

# to make life easier and more pleasant :)
# more: http://aledalgrande.posterous.com/52292198
# haml-rails instead haml is required for generators to make HAML default instead of ERB.
gem 'coffee-filter'
gem 'haml-rails'

gem 'rails_config'
gem 'state_machine'

gem 'will_paginate', :git => 'https://github.com/p7r/will_paginate.git', :branch => 'rails3'
gem 'annotate'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', "~> 3.2.0"
  gem 'uglifier'
end

gem 'jquery-rails'
# gem 'taps'

# Gravatar
gem 'gravatar_image_tag'

# Sass was in assets group, but it is required by activeadmin.
gem 'sass-rails', "~> 3.2.0"

# Admin Panel
gem 'activeadmin'

# Levenshtein
gem 'text'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

group :development, :test do
  gem 'annotate'
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'shoulda'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end

# for Heroku
group :production do
  gem 'pg'
  gem 'therubyracer'
end
