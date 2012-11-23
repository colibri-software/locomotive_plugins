require 'rubygems'
require 'rake'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'version'

require 'bundler/gem_tasks'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: :spec
