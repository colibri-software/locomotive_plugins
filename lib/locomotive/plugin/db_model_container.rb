
module Locomotive
  module Plugin
    # The superclass of the DBModelContainer object for each plugin
    class DBModelContainer
      include Mongoid::Document
    end
  end
end
