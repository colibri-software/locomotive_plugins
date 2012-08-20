# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'version'

Gem::Specification.new do |s|
  s.name        = 'locomotive_plugins'
  s.version     = LocomotivePlugins::VERSION
  s.date        = Date.today.to_s

  s.summary             = 'Gem for creating plugins for Locomotive'
  s.description         = 'This gem allows developers to create plugins for Locomotive CMS with particular functionality. See the README for more details'

  s.authors             = ['Colibri Software']
  s.email               = 'info@colibri-software.com'
  s.homepage            = 'http://www.colibri-software.com'

  s.add_dependency 'locomotive_liquid', '~> 2.2.2'

  s.files        = Dir['Rakefile',
    *%w{bin,lib,man,test,spec}.collect { |dir| "#{dir}/**/*" },
    *%w{README LICENSE CHANGELOG}.collect { |file| "#{file}*" }
  ]

  if s.respond_to? :specification_version
    s.specification_version = 3
  end
end
