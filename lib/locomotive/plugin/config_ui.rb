
module Locomotive
  module Plugin
    # @private
    module ConfigUI

      protected

      def default_config_template_string
        filepath = self.config_template_file

        if filepath
          filepath = filepath.to_s
          if filepath.end_with?('haml')
            Haml::Engine.new(IO.read(filepath)).render
          else
            IO.read(filepath)
          end
        else
          nil
        end
      end

    end
  end
end
