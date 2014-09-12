# encoding: utf-8

module TokiCLI

  class TokiAPI

    require 'json'
    require 'amalgalite'

    require_relative 'helpers'
    require_relative 'toki_db'

    attr_reader :bundles, :response

    def initialize(db_path, bundles = nil)
      @db = TokiDB.new(db_path)
      @helpers = Helpers.new
      @bundles = bundles
    end

    def apps_total
      request = {command: 'apps_total', type: 'apps', args: [], processed_at: Time.now}
      resp = @db.apps_total
      return no_resp(request) if resp.empty?
      result = make_apps_objects(resp)
      list = result.sort_by {|obj| obj[:total][:seconds]}
      @response = make_basic_response(request, list)
    end

    private

    def make_basic_response(request, list)
      {
        meta: {
          code: 200,
          request: request
        },
        data: list
      }.to_json
    end

    def make_apps_objects(db_resp)
      if @bundles.nil?
        db_resp.map do |id, sec|
          {
            bundle: id,
            total: {
              seconds: sec,
              time: @helpers.sec_to_time(sec)
            }
          }
        end
      else
        db_resp.map do |id, sec|
          {
            bundle: id,
            name: @bundles[id],
            total: {
              seconds: sec,
              time: @helpers.sec_to_time(sec)
            }
          }
        end
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
