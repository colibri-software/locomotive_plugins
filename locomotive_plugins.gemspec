# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'version'

Gem::Specification.new do |s|
  s.name        = 'locomotive_plugins'
  s.version     = LocomotivePlugins::VERSION

  s.summary             = 'Gem for creating plugins for Locomotive'
  s.description         = 'This gem allows developers to create plugins for Locomotive CMS with particular functionality. See the README for more details'

  s.authors             = ['Colibri Software']
  s.email               = 'info@colibri-software.com'
  s.homepage            = 'https://github.com/colibri-software/locomotive_plugins'

  s.add_dependency 'locomotive_liquid', '~> 2.4'
  s.add_dependency 'haml',              '~> 4.0'

  s.add_dependency 'bson_ext'
  s.add_dependency 'mongoid',           '~> 3.1.5'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.files        = Dir['Rakefile',
    *%w{bin lib man test spec}.collect { |dir| "#{dir}/**/*" },
    *%w{README LICENSE CHANGELOG}.collect { |file| "#{file}*" }
  ]

  s.required_ruby_version = '~> 1.9'
end
