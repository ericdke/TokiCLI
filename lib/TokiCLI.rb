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
      init() # Alternative: init(true). Backups the db before using it.
      apps = @toki.apps_total() # gets the JSON response from TokiAPI
      if options[:json] || options[:csv]
        @fileops.export(@toki, options) # the response was stocked in @toki when .apps_total was called
      else
        title = "Toki - Total usage of all apps"
        @view.apps_total(apps, title) # Title is optional: @view.apps_total(apps)
      end
    end

    desc "top", "Most used apps"
    option :number, aliases: '-n', type: :numeric, desc: 'Specify the number of apps'
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results in a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results in a CSV file'
    def top
      init()
      max = options[:number] || 5
      apps = @toki.apps_top(max)
      if options[:json] || options[:csv]
        @fileops.export(@toki, options)
      else
        @view.apps_total(apps, "Toki - Total usage of most used apps")
      end
    end

    private

    # Replaces usual initialize method
    def init(backup = false)
      @fileops = FileOps.new
      @fileops.backup_db if backup == true
      @toki = TokiAPI.new(@fileops.db_path, @fileops.bundles) # @fileops.bundles is optional
      @view = View.new
    end

  end
end
