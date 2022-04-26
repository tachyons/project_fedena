source 'https://rubygems.org'

gem 'i18n', '~> 0.4.2'
# gem "searchlogic", "~> 2.3.5"
gem 'wicked_pdf', "2.6.0"
gem "activerecord-mysql2-adapter"
gem 'rush', '~> 0.6.7'
gem 'declarative_authorization','~> 0.5.1'
gem 'haml', "~> 3.1"
gem 'pry'
gem 'passenger'
git 'https://github.com/makandra/rails.git', :branch => '2-3-lts' do
  gem 'rails', '~>2.3.18'
  gem 'actionmailer',     :require => false
  gem 'actionpack',       :require => false
  gem 'activerecord',     :require => false
  gem 'activeresource',   :require => false
  gem 'activesupport',    :require => false
  gem 'railties',         :require => false
  gem 'railslts-version', :require => false
end
# bundler requires these gems in all environments
# gem 'nokogiri', '1.4.2'
# gem 'geokit'

group :development do
  # bundler requires these gems in development
  # gem 'rails-footnotes'
end

group :test do
  # bundler requires these gems while running tests
  gem 'rspec'
  gem 'factory_girl'
  gem 'database_cleaner', "~> 0.9"
  gem 'test-unit'
end
