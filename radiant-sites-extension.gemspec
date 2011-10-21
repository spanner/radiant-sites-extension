# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-sites-extension"

Gem::Specification.new do |s|
  s.name        = "radiant-sites-extension"
  s.version     = RadiantSitesExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = RadiantSitesExtension::AUTHORS
  s.email       = RadiantSitesExtension::EMAIL
  s.homepage    = RadiantSitesExtension::URL
  s.summary     = RadiantSitesExtension::SUMMARY
  s.description = RadiantSitesExtension::DESCRIPTION

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]

  s.post_install_message = %{
  Add this to your radiant project with a line in your Gemfile:

    gem 'radiant-sites-extension', '~> #{RadiantSitesExtension::VERSION}'

  }

end