
module Locomotive
  module Plugin

    # General Locomotive::Plugin exception
    class Error < StandardError; end

    # Error while plugin is being initialized
    class InitializationError < Error; end

  end
end
