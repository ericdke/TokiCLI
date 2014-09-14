# encoding: utf-8
require 'thor'

module TokiCLI
  class App < Thor

    package_name "TokiCLI"

    require_relative 'API/toki_api'
    %w{version status fileops view}.each {|r| require_relative "TokiCLI/#{r}"}

    desc "version", "TokiCLI version number"
    map "-v" => :version
    def version
      View.new.version
    end

    desc "scan", "Scan applications folders for full names"
    def scan
      puts Status.scanning
      fileops = FileOps.new
      fileops.save_bundles
      puts Status.file_saved(fileops.bundles_path)
      puts Status.next_launch_with_names
    end

    desc "total", "Show total for all apps"
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

    desc "top", "Show total for most used apps"
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

    desc "day DATE", "Show total for apps used on a specific day"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results in a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results in a CSV file'
    def day(*args)
      init()
      @toki.apps_day(args[0])
      exit_with_msg_if_invalid_response()
      @view.apps_total(@toki.response, "Toki - All apps used on #{args[0]}")
      export(@toki, options)
    end

    desc "range DATE1 DATE2", "Show total for all apps used between two specific days"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results in a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results in a CSV file'
    def range(*args)
      init()
      @toki.apps_range(args[0], args[1])
      exit_with_msg_if_invalid_response()
      @view.apps_total(@toki.response, "Toki - All apps used between #{args[0]} and #{args[1]}")
      export(@toki, options)
    end

    desc "since DATE", "Show total for all apps used since a specific day"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results in a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results in a CSV file'
    def since(*args)
      init()
      @toki.apps_since(args[0])
      exit_with_msg_if_invalid_response()
      @view.apps_total(@toki.response, "Toki - All apps used since #{args[0]}")
      export(@toki, options)
    end

    desc "before DATE", "Show total for all apps used before a specific day"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results in a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results in a CSV file'
    def before(*args)
      init()
      @toki.apps_before(args[0])
      exit_with_msg_if_invalid_response()
      @view.apps_total(@toki.response, "Toki - All apps used before #{args[0]}")
      export(@toki, options)
    end

    desc "bundle BUNDLE_ID", "Show complete log for an app from its exact bundle id"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results as a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results as a CSV file'
    option :since, type: :string, desc: 'Request log starting on this date'
    option :day, type: :string, desc: 'Request log for a specific day'
    def bundle(bundle_id)
      init()
      title = "Toki - Complete log for #{bundle_id}"
      if options[:since]
        @toki.bundle_log_since(bundle_id, options[:since])
        title += " since #{options[:since]}"
      elsif options[:day]
        @toki.bundle_log_day(bundle_id, options[:day])
        title += " for #{options[:day]}"
      else
        @toki.bundle_log(bundle_id)
      end
      exit_with_msg_if_invalid_response()
      @view.log_table(@toki.response, title)
      export(@toki, options)
    end

    desc "app APP_NAME", "Show complete log for an app from (part of) its name"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results as a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results as a CSV file'
    def app(*app_name)
      init()
      abort(Status.please_scan) if @fileops.bundles.nil?
      candidates = @fileops.get_bundle_from_name(app_name)
      candidates.each.with_index(1) do |bundle_id, index|
        puts "\nApp N°#{'%.2d' % index}: #{bundle_id}\n" if candidates.length > 1
        @toki.bundle_log(bundle_id)
        if JSON.parse(@toki.response)['meta']['code'] != 200
          puts "\nError, skipping this app.\n\n"
          next
        end
        @view.log_table(@toki.response, "Toki - Complete log for #{bundle_id}")
        export(@toki, options)
      end
    end


    private

    def exit_with_msg_if_invalid_response(msg = Status.wtf)
      abort(msg) if JSON.parse(@toki.response)['meta']['code'] != 200
    end

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
