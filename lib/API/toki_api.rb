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
      return apps_response_wrapper(request, resp)
    end

    def apps_top(number = 5)
      request = {command: 'apps_top', type: 'apps', args: [number], processed_at: Time.now}
      resp = @db.apps_total
      return invalid_response(request) if resp.empty?
      index = -number
      list = make_apps_list(request, resp)[index..-1]
      @response = make_basic_response(request, list)
    end

    def apps_day(day)
      request = {command: 'apps_day', type: 'apps', args: [day], processed_at: Time.now}
      date = @helpers.check_date_validity(day)
      return invalid_response(request) if date == false
      resp = @db.apps_range(date.to_time.to_i, date.next_day.to_time.to_i)
      return apps_response_wrapper(request, resp)
    end

    def apps_range(day1, day2)
      request = {command: 'apps_range', type: 'apps', args: [day1, day2], processed_at: Time.now}
      starting, ending = @helpers.check_date_validity(day1), @helpers.check_date_validity(day2)
      return invalid_response(request) if starting == false || ending == false || starting > ending
      resp = @db.apps_range(starting.to_time.to_i, ending.to_time.to_i)
      return apps_response_wrapper(request, resp)
    end

    def apps_since(day)
      request = {command: 'apps_since', type: 'apps', args: [day], processed_at: Time.now}
      starting = @helpers.check_date_validity(day)
      return invalid_response(request) if starting == false
      resp = @db.apps_since(starting.to_time.to_i)
      return apps_response_wrapper(request, resp)
    end

    def apps_before(day)
      request = {command: 'apps_before', type: 'apps', args: [day], processed_at: Time.now}
      ending = @helpers.check_date_validity(day)
      return invalid_response(request) if ending == false
      resp = @db.apps_before(ending.to_time.to_i)
      return apps_response_wrapper(request, resp)
    end

    def bundle_log(bundle)
      request = {command: 'bundle_log', type: 'log', args: [bundle], processed_at: Time.now}
      resp = @db.bundle_log(bundle)
      return invalid_response(request) if resp.empty?
      list = make_log_objects(resp)
      @response = make_basic_response(request, list)
    end

    private

    def apps_response_wrapper(request, resp)
      return invalid_response(request) if resp.empty?
      list = make_apps_list(request, resp)
      @response = make_basic_response(request, list)
    end

    def invalid_response(request)
      @response = no_resp(request)
    end

    def make_apps_list(request, resp)
      result = make_apps_objects(resp)
      result.sort_by {|obj| obj[:total][:seconds]}
    end

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

    def make_log_objects(db_resp)
      result = {}
      sorted = db_resp.sort_by { |arr| arr[2] }
      sorted.each do |arr|
        result[arr[0]] = {
          start: @helpers.epoch_to_date(arr[2]),
          duration: {
            seconds: arr[4],
            time: @helpers.sec_to_time(arr[4])
          }
        }
      end
      return result
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
