# encoding: utf-8
module TokiCLI

  module Status

    module ClassMethods

      def canceled
        "\nCanceled.\n\n"
      end

      def version(version)
        "\n-- TokiCLI --\n\nVersion:\t#{version}\nUrl:\t\thttp://github.com/ericdke/TokiCLI\n\n"
      end

      def wtf
        "\nAn error occurred! Goodbye, and thanks for all the fish.\n\n"
      end

      def no_plist
        "Unable to read the file, skipping...\n"
      end

      def no_data
        "\nNo data for this request.\n\n"
      end

      def analysing(obj)
        "Analyzing #{obj} ...\n"
      end

      def scanning
        "\nScanning applications bundles to find their names.\n\n"
      end

      def file_saved(path)
        "\nFile saved in #{path}\n\n"
      end

      def next_launch_with_names
        "Starting with next launch, TokiCLI will display apps names. Run `toki scan` again to update the apps list.\n\n"
      end

      def please_scan
        "\nPlease run `toki scan` to populate/refresh the applications names database.\n\n"
      end

    end

    extend ClassMethods # This is a way to avoid having to declare self.xxx for each def
  end

end
