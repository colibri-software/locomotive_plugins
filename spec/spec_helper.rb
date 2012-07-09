ENV['RAILS_ENV'] ||= 'test'

require 'rubygems'
require 'bundler'

require 'rspec'

require 'factory_girl'



# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}


$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))


#FactoryGirl.find_definitions

RSpec.configure do |config|
  config.mock_with :mocha
  
   # Use color in STDOUT
  config.color_enabled = true

end
