# encoding: utf-8
module TokiCLI
  module Status
    module ClassMethods
      def version(version)
        "\n-- TokiCLI --\n\nVersion:\t#{version}\nUrl:\t\thttp://github.com/ericdke/TokiCLI\n\n"
      end
    end
    extend ClassMethods # This is a way to avoid having to declare self.xxx for each def
  end
end
