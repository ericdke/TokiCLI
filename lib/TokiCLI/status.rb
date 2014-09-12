# encoding: utf-8
module TokiCLI
  module Status
    module ClassMethods
      def version(version)
        "\n-- TokiCLI --\n\nVersion:\t#{version}\nUrl:\t\thttp://github.com/ericdke/TokiCLI\n\n"
      end
      def wtf
        "\nAn error occurred! Goodbye, and thanks for all the fish.\n\n"
      end
      def no_plist
        "Unable to read the file, skipping...\n"
      end

      def analysing(obj)
        "Analyzing #{obj} ...\n"
      end
    end
    extend ClassMethods # This is a way to avoid having to declare self.xxx for each def
  end
end
