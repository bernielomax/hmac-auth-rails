$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hmac_auth_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hmac-auth-rails"
  s.version     = HmacAuthRails::VERSION
  s.authors     = ["Justin Pye"]
  s.homepage    = "https://github.com/bernielomax/hmac-auth-rails"
  s.summary     = "Provides HMAC authentication to your Rails controllers"
  s.description = "Provides HMAC authentication to your Rails controllers"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.2"
  s.add_dependency "devise", "~>3.4"

  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "jbuilder", "~> 2.0"
  s.add_development_dependency "rspec-rails", "~> 3.0"
  s.add_development_dependency "factory_girl_rails", "~> 4.0"
end
