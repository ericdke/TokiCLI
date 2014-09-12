# encoding: utf-8

module TokiCLI

  class TokiAPI

    require 'json'
    require 'amalgalite'
    require 'CFPropertyList'

    require_relative 'helpers'

    attr_accessor :db

    def initialize(toki_db)
      @table = 'KKAppActivity'
      @db = toki_db
      @helpers = Helpers.new
    end

    def apps_total
      resp = @db.execute("SELECT bundleIdentifier,sum(totalSeconds) FROM #{@table} GROUP BY bundleIdentifier")
      result = resp.map do |id, sec|
        {
          bundle: id,
          # name: @helpers.find_app_name(id),
          total: {
            seconds: sec,
            time: @helpers.sec_to_time(sec)
          }
        }
      end
      result.sort_by! {|obj| obj[:total][:seconds]}
      result.to_json
    end

  end

end
