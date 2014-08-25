module Locomotive
  module Plugin
    # This module add helpers for using js3 (JavaScript on the Server Side)
    module JS3

      # The js3 context
      #
      # @return a V8 context object
      def js3_context
        Locomotive::Plugins.js3_context
      end

    end
  end
end
