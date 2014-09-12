# encoding: utf-8

module TokiCLI

  class TokiAPI

    require 'json'
    require 'amalgalite'

    require_relative 'helpers'

    attr_accessor :db

    def initialize(db_path)
      @table = 'KKAppActivity'
      @db = Amalgalite::Database.new(db_path)
      @helpers = Helpers.new
    end

    def apps_total
      resp = @db.execute("SELECT bundleIdentifier,sum(totalSeconds) FROM #{@table} GROUP BY bundleIdentifier")
      request = {command: 'apps_total', args: [], processed_at: Time.now}
      return no_resp(request) if resp.empty?
      result = make_apps_objects(resp)
      list = result.sort_by {|obj| obj[:total][:seconds]}
      return {
        meta: {
          code: 200,
          request: request
        },
        data: list
      }.to_json
    end

    private

    def make_apps_objects(db_resp)
      db_resp.map do |id, sec|
        {
          bundle: id,
          # name: @helpers.find_app_name(id),
          total: {
            seconds: sec,
            time: @helpers.sec_to_time(sec)
          }
        }
      end
    end

    def no_resp(request)
      {
        meta: {
          code: 422,
          request: request
        },
        data: []
      }.to_json
    end

  end

end
