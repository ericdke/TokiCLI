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
      puts Status.version(VERSION)
    end

    desc "total", "Total usage of all apps"
    def total
      init()
      res = JSON.parse(@toki.apps_total)
      @view.apps_total(res)
    end

    private

    def init
      fileops = FileOps.new
      fileops.backup_db()
      @toki = TokiAPI.new(Amalgalite::Database.new(fileops.db_path))
      @view = View.new
    end

  end
end
