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

    desc "total", "Total usage of all apps"
    def total
      init() #option: true/false for db backup/no db backup, false by default
      apps = @toki.apps_total
      title = "Toki: Total usage of all apps" #optional
      @view.apps_total(apps, title)
    end

    private

    def init(backup = false)
      fileops = FileOps.new
      fileops.backup_db() if backup == true
      @toki = TokiAPI.new(fileops.db_path)
      @view = View.new
    end

  end
end
