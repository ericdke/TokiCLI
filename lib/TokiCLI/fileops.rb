# encoding: utf-8
module TokiCLI
  class FileOps

    require 'fileutils'

    attr_accessor :toki_path, :db_path

    def initialize
      @home_path = Dir.home
      @toki_path = "#{@home_path}/.TokiCLI"
      @db_path = "#{@home_path}/Library/Containers/us.kkob.Toki/Data/Documents/toki_data.sqlite3"
    end

    def backup_db
      make_toki_dir()
      if File.exist?(@db_path)
        FileUtils.copy(@db_path, "#{@toki_path}/backup/toki_data.sqlite3.bak")
      else
        raise "File does not exist: #{@db_path}"
      end
    end

    def make_toki_dir
      FileUtils.mkdir_p(@toki_path) unless Dir.exist?(@toki_path)
      FileUtils.mkdir("#{@toki_path}/backup") unless Dir.exist?("#{@toki_path}/backup")
      FileUtils.mkdir("#{@toki_path}/data") unless Dir.exist?("#{@toki_path}/data")
      FileUtils.mkdir("#{@toki_path}/config") unless Dir.exist?("#{@toki_path}/config")
    end

  end
end
