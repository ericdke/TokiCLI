# encoding: utf-8
require 'thor'

module TokiCLI
  class App < Thor

    package_name "TokiCLI"

    require_relative 'API/toki_api'
    %w{version status fileops view}.each {|r| require_relative "TokiCLI/#{r}"}

    desc "version", "Display TokiCLI version number"
    map "-v" => :version
    def version
      View.new.version
    end

    desc "scan", "Scan the computer for applications names"
    def scan
      puts Status.scanning
      fileops = FileOps.new
      fileops.save_bundles
      puts Status.file_saved(fileops.bundles_path)
      puts Status.next_launch_with_names
    end

    desc "total", "All apps"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results in a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results in a CSV file'
    def total
      # Initializes files and instances
      ## Replace with init(true) to backup the db before using it
      ## Not necessary for read-only commands like this one
      init()
      # Gets the JSON response from TokiAPI
      ## Here the response is stocked locally in 'apps' but using a variable is optional:
      ## the response is memoized in @toki.response when a @toki method is called
      ## (see other commands)
      apps = @toki.apps_total()
      # Title is optional: @view.apps_total(apps)
      title = "Toki - Total usage of all apps"
      @view.apps_total(apps, title)
      # Exports only if options are present
      export(@toki, options)
    end

    desc "top", "Most used apps"
    option :number, aliases: '-n', type: :numeric, desc: 'Specify the number of apps'
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results in a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results in a CSV file'
    def top
      init()
      max = options[:number] || 5
      @toki.apps_top(max)
      @view.apps_total(@toki.response, "Toki - Total usage of most used apps")
      export(@toki, options)
    end

    private

    def export(toki, options)
      if options[:json] || options[:csv]
        @fileops.export(toki, options)
      end
    end

    # Replaces usual initialize method
    def init(backup = false)
      @fileops = FileOps.new
      @fileops.backup_db if backup == true
      @toki = TokiAPI.new(@fileops.db_path, @fileops.bundles) # @fileops.bundles is optional
      @view = View.new
    end

  end
end
