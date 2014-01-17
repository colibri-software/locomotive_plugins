
require 'rubygems'
require 'bundler'

require 'rspec'

require 'factory_girl'
require 'database_cleaner'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'locomotive_plugins'

# Set up mongoid
ENV["MONGOID_ENV"] = "test"
Mongoid.load!('spec/support/mongoid.yml')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha

   # Use color in STDOUT
  config.color_enabled = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = 'mongoid'
  end

  config.before(:each) do
    Mongoid::IdentityMap.clear
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end

end
