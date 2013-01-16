
module Locomotive
  module Plugin
    # @api internal
    #
    # Helpers for setting up configuration UI.
    module ConfigUI

      protected

      # By default, fetch the contents of the file given by
      # +config_template_file+. If it is HAML, convert it to HTML. Then return
      # the contents.
      #
      # @param filepath [String] the file path to read from
      # @return the contents of the file at +filepath+, parsed by HAML if
      #         needed
      def default_config_template_string(filepath)
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
