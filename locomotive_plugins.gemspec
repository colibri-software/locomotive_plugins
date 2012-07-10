# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'version'

Gem::Specification.new do |s|
  s.name = "locomotive_plugins"
  s.version = LocomotivePlugins::VERSION
  s.platform    = Gem::Platform::RUBY

  s.authors = ["Colibri Software"]
  s.date = "2012-07-09"
  s.description = "Gem for creating plugins for Locomotive"
  s.email = "info@colibri-software.com"
  s.extra_rdoc_files = ["lib/locomotive_plugins.rb"]
  s.files = ["Rakefile", "lib/locomotive_plugins.rb", "Manifest", "locomotive_plugins.gemspec"]
  s.homepage = "http://www.colibri-software.com"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Locomotive Plugins"]
  s.require_paths = ["lib"]
  s.summary = "lib/locomotive_plugins.rb"

  s.required_rubygems_version = ">= 1.3.6"

  s.files        = Dir["Rakefile",
    'Gemfile',
    '{lib}/**/*',
    '{vendor}/**/*']

  if s.respond_to? :specification_version
    s.specification_version = 3
  end
end
