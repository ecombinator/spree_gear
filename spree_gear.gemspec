# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_gear/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_gear'
  s.version     = SpreeGear.version
  s.summary     = 'Improvements to backend spree'
  s.description = s.summary
  s.required_ruby_version = '>= 2.2.2'

  s.authors    = 'Jibril Tapiador'
  s.email     = 'tapiador.jib@gmail.com'
# s.homepage  = 'https://github.com/your-github-handle/spree_gear'
  s.license = 'BSD-3-Clause'

# s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '>= 3.1.0', '< 4.0'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'capybara-screenshot'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'appraisal'

  s.add_runtime_dependency 'jquery-datatables-rails'
  s.add_runtime_dependency 'ajax-datatables-rails'
  s.add_runtime_dependency 'spree_volume_pricing'
end
