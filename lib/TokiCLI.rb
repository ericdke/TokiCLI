# encoding: utf-8
require 'thor'

module TokiCLI
  class App < Thor

    package_name "TokiCLI"

    require_relative 'API/toki_api'
    %w{version status fileops view adnimport}.each {|r| require_relative "TokiCLI/#{r}"}

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
      puts Status.file_saved(fileops.bundles_file)
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
      # Export or display
      if options[:json] || options[:csv]
        export(@toki, options)
      else
        # Title is optional: @view.apps_total(apps)
        title = "Toki - Total usage of all apps"
        @view.apps_total(apps, title)
      end
    end

    desc "top", "Show total for most used apps"
    option :number, aliases: '-n', type: :numeric, desc: 'Specify the number of apps'
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results in a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results in a CSV file'
    def top
      init()
      max = options[:number] || 5
      @toki.apps_top(max)
      if options[:json] || options[:csv]
        export(@toki, options)
      else
        @view.apps(@toki.response, "Toki - Total usage of most used apps")
      end
    end

    desc "day DATE", "Show total for apps used on a specific day"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results in a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results in a CSV file'
    def day(*args)
      init()
      @toki.apps_day(args[0])
      exit_with_msg_if_invalid_response()
      if options[:json] || options[:csv]
        export(@toki, options)
      else
        @view.apps(@toki.response, "Toki - All apps used on #{args[0]}")
      end
    end

    desc "range DATE1 DATE2", "Show total for all apps used between two specific days"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results in a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results in a CSV file'
    def range(*args)
      init()
      @toki.apps_range(args[0], args[1])
      exit_with_msg_if_invalid_response()
      if options[:json] || options[:csv]
        export(@toki, options)
      else
        @view.apps(@toki.response, "Toki - All apps used between #{args[0]} and #{args[1]}")
      end
    end

    desc "since DATE", "Show total for all apps used since a specific day"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results in a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results in a CSV file'
    def since(*args)
      init()
      @toki.apps_since(args[0])
      exit_with_msg_if_invalid_response()
      if options[:json] || options[:csv]
        export(@toki, options)
      else
        @view.apps(@toki.response, "Toki - All apps used since #{args[0]}")
      end
    end

    desc "before DATE", "Show total for all apps used before a specific day"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results in a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results in a CSV file'
    def before(*args)
      init()
      @toki.apps_before(args[0])
      exit_with_msg_if_invalid_response()
      if options[:json] || options[:csv]
        export(@toki, options)
      else
        @view.apps(@toki.response, "Toki - All apps used before #{args[0]}")
      end
    end

    desc "activity", "Shows recent log updates"
    option :since, type: :string, desc: 'Request log starting on this date'
    option :day, type: :string, desc: 'Request log for a specific day'
    def activity
      init()
      if options.since?
        @toki.log_since(options.since)
      elsif options.day?
        @toki.log_day(options.day)
      else
        @toki.log_since()
      end
      @view.log_activity(@toki.response)
    end

    desc "bundle BUNDLE_ID", "Show complete log for an app from its exact bundle id"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results as a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results as a CSV file'
    option :before, type: :string, desc: 'Request log before this date'
    option :since, type: :string, desc: 'Request log starting on this date'
    option :day, type: :string, desc: 'Request log for a specific day'
    option :range, type: :array, desc: 'Request log between two specific days'
    def bundle(bundle_id)
      init()
      title = bundle_title(bundle_id, options)
      bundle_log(bundle_id, options)
      exit_with_msg_if_invalid_response(Status.no_data)
      if options[:json] || options[:csv]
        export(@toki, options)
      elsif options[:since] || options[:before] || options[:day] || options[:range]
        @view.log(@toki.response, title)
      else
        @view.log_total(@toki.response, title)
      end
    end

    desc "app APP_NAME", "Show complete log for an app from (part of) its name"
    option :json, aliases: '-J', type: :boolean, desc: 'Export the results as a JSON file'
    option :csv, aliases: '-C', type: :boolean, desc: 'Export the results as a CSV file'
    option :before, type: :string, desc: 'Request log before this date'
    option :since, type: :string, desc: 'Request log starting on this date'
    option :day, type: :string, desc: 'Request log for a specific day'
    option :range, type: :array, desc: 'Request log between two specific days'
    def app(*app_name)
      init()
      abort(Status.please_scan) if @toki.bundles.nil?
      candidates = @fileops.get_bundle_from_name(app_name)
      candidates.each.with_index(1) do |bundle_id, index|
        say "\nApp N°#{'%.2d' % index}: #{bundle_id}" if candidates.length > 1
        bundle_log(bundle_id, options)
        if JSON.parse(@toki.response)['meta']['code'] != 200
          say Status.no_data
        else
          if options[:json] || options[:csv]
            export(@toki, options, bundle_id)
          elsif options[:since] || options[:before] || options[:day] || options[:range]
            @view.log(@toki.response, bundle_title(bundle_id, options))
          else
            @view.log_total(@toki.response, bundle_title(bundle_id, options))
          end
        end
      end
    end

    desc "restore", "Restore your database from the App.net backup"
    def restore
      init(true)
      adn = ADNImport.new(@fileops.data_path)
      adn.restore
    end

    desc "serve", "Start a local Toki API server"
    map "server" => :serve
    def serve
      require_relative '../lib/TokiServer/tokiserver'
      puts "\n\n"
      say_status :starting, "Toki API server"
      say "\n\nPress [CTRL-C] to stop.\n\nThe index page URL is: http://localhost:4567\n\n"
      TokiServer.run!
      puts "\n\n"
      say_status :halt, "Toki API server"
    end

    # ---

    desc "delete BUNDLE_ID", "Permanently delete this application from the database"
    option :'no-backup', aliases: '-X',type: :boolean, desc: 'Do not backup the database before processing'
    def delete(bundle_id)
      options['no-backup'] ? init() : init(true)
      name = @toki.bundles[bundle_id]
      confirm_delete(bundle_id, name)
      say "\nDeleting entries..."
      @toki.delete_bundle(bundle_id)
      exit_with_msg_if_invalid_response(Status.wtf)
      say "\nDone.\n"
    end

    private

    def confirm_delete(bundle_id, name)
      name.nil? ? insert = '' : insert = " (#{name})"
      xx = yes?("\nAre you sure you want to remove all '#{bundle_id}'#{insert} entries from the database ?\n\n>> ")
      abort("\nCanceled.\n\n") if xx == false
    end

    def bundle_log(bundle_id, options)
      if options[:since]
        @toki.bundle_log_since(bundle_id, options[:since])
      elsif options[:before]
        @toki.bundle_log_before(bundle_id, options[:before])
      elsif options[:day]
        @toki.bundle_log_day(bundle_id, options[:day])
      elsif options[:range]
        @toki.bundle_log_range(bundle_id, options[:range][0], options[:range][1])
      else
        @toki.bundle_log(bundle_id)
      end
    end

    def bundle_title(bundle_id, options = {})
      prefix = "Toki - Complete log for #{bundle_id}"
      if options[:since]
        "#{prefix} since #{options[:since]}"
      elsif options[:before]
        "#{prefix} before #{options[:before]}"
      elsif options[:day]
        "#{prefix} - #{options[:day]}"
      elsif options[:range]
        "#{prefix} - #{options[:range][0]}/#{options[:range][1]}"
      else
        prefix
      end
    end

    def exit_with_msg_if_invalid_response(msg = Status.wtf)
      abort(msg) if JSON.parse(@toki.response)['meta']['code'] != 200
    end

    def export(toki, options, title = nil)
      @fileops.export(toki, options, title)
    end

    # Replaces usual initialize method
    def init(backup = false)
      @fileops = FileOps.new
      @fileops.backup_db if backup == true
      @toki = TokiAPI.new(@fileops.db_file, @fileops.bundles) # @fileops.bundles is optional
      @view = View.new(@fileops.config) # @fileops.config is optional
    end

  end
end
