#!/usr/bin/env ruby
# encoding: utf-8

require "sinatra"
require "sinatra/assetpack"
require_relative '../API/toki_api'
require_relative '../TokiCLI/fileops'
require_relative "itunesicons"
require "sinatra/reloader"

class TokiServer < Sinatra::Application

  class Getters

    def initialize(toki, fileops)
      @toki = toki
      @fileops = fileops
    end

    def bundles_from_name(bundles)
      @fileops.get_bundle_from_name(Array(bundles))
    end

  end

  # TOKI INIT

  fileops = TokiCLI::FileOps.new
  toki = TokiCLI::TokiAPI.new(fileops.db_file, fileops.bundles)
  # Each toki instance has @response, which always contains the last result from a command
  # So you can go with state (updated toki.response) or stateless (create new TokiAPI instances)
  getters = Getters.new(toki, fileops)
  icons = ItunesIcons.new(fileops)


  # SINATRA INIT

  configure :development do
    register Sinatra::Reloader
  end

  configure do
    file = File.new("#{fileops.log_path}/server.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end

  set :server, %w[thin webrick]
  set :port, 4567
  set :root, File.dirname(__FILE__)

  assets do
    serve '/js', :from => 'js'
    serve '/bower_components', :from => 'bower_components'
    # serve '/css', :from => 'public/stylesheets'

    # css :application, '/stylesheets/app.css', [
    #   '/stylesheets/app.css'
    # ]

    js :modernizr, [
      '/bower_components/modernizr/modernizr.js',
    ]

    js :libs, [
      '/bower_components/jquery/dist/jquery.js',
      '/bower_components/foundation/js/foundation.js'
    ]

    js :application, [
      '/js/app.js'
    ]

    js_compression :jsmin
  end


  # WEB ROUTES

  get '/' do
    erb :index
  end

  get '/apps/total/?' do
    data = JSON.parse(toki.apps_total)['data']
    total = toki.helpers.calc_apps_total(data)
    erb :apps_total, locals: { toki: toki, title: 'Total', data: data, total: total }
  end

  get '/apps/top/?:number?' do
    data = if params[:number]
      max = params[:number].to_i
      JSON.parse(toki.apps_top(max))['data']
    else
      JSON.parse(toki.apps_top)['data']
    end
    erb :apps_total, locals: { toki: toki, title: 'Total', data: data, total: nil }
  end

  get '/apps/day/?:day?' do
    day = params[:day]
    data = JSON.parse(toki.apps_day(day))['data']
    erb :apps_total, locals: { toki: toki, title: 'Total', data: data, total: nil }
  end

  get '/apps/range/:day1/?:day2?' do
    day1, day2 = params[:day1], params[:day2]
    data = JSON.parse(toki.apps_range(day1, day2))['data']
    erb :apps_total, locals: { toki: toki, title: 'Total', data: data, total: nil }
  end

  get '/apps/since/?:day?' do
    day = params[:day]
    data = JSON.parse(toki.apps_since(day))['data']
    erb :apps_total, locals: { toki: toki, title: 'Total', data: data, total: nil }
  end

  get '/apps/before/?:day?' do
    day = params[:day]
    data = JSON.parse(toki.apps_before(day))['data']
    erb :apps_total, locals: { toki: toki, title: 'Total', data: data, total: nil }
  end

  get '/activity/?' do
    data = JSON.parse(toki.log_since)['data']
    erb :activity, locals: { toki: toki, title: 'Activity', data: data, total: nil, name: 'Recent activity', icon: nil }
  end

  get '/activity/day/?:day?' do
    day = params[:day]
    data = JSON.parse(toki.log_day(day))['data']
    total = toki.helpers.calc_logs_total(data)
    erb :activity, locals: { toki: toki, title: 'Activity', data: data, total: total, name: "#{day} -", icon: nil }
  end

  get '/activity/since/?:day?' do
    day = params[:day]
    data = JSON.parse(toki.log_since(day))['data']
    total = toki.helpers.calc_logs_total(data)
    erb :activity, locals: { toki: toki, title: 'Activity', data: data, total: total, name: "Since #{day} -", icon: nil }
  end

  get '/logs/bundle/:bundle/total/?' do
    bundle = params[:bundle]
    data = JSON.parse(toki.bundle_log(bundle))['data']
    name = toki.bundles[bundle]
    icon_url = icons.grab_small(name)
    erb :activity, locals: { toki: toki, title: 'Total', data: data, total: nil, name: "#{bundle} - #{name}", icon: icon_url }
  end

  get '/logs/bundle/:bundle/day/?:day?' do
    bundle, day = params[:bundle], params[:day]
    data = JSON.parse(toki.bundle_log_day(bundle, day))['data']
    total = toki.helpers.calc_logs_total(data)
    name = toki.bundles[bundle]
    icon_url = icons.grab_small(name)
    erb :activity, locals: { toki: toki, title: 'Total', data: data, total: total, name: "#{bundle} - #{name} -", icon: icon_url  }
  end

  get '/logs/bundle/:bundle/since/?:day?' do
    bundle, day = params[:bundle], params[:day]
    data = JSON.parse(toki.bundle_log_since(bundle, day))['data']
    total = toki.helpers.calc_logs_total(data)
    name = toki.bundles[bundle]
    icon_url = icons.grab_small(name)
    erb :activity, locals: { toki: toki, title: 'Total', data: data, total: total, name: "#{bundle} - #{name} -", icon: icon_url  }
  end

  get '/logs/bundle/:bundle/before/?:day?' do
    bundle, day = params[:bundle], params[:day]
    data = JSON.parse(toki.bundle_log_before(bundle, day))['data']
    total = toki.helpers.calc_logs_total(data)
    name = toki.bundles[bundle]
    icon_url = icons.grab_small(name)
    erb :activity, locals: { toki: toki, title: 'Total', data: data, total: total, name: "#{bundle} - #{name} -", icon: icon_url  }
  end

  get '/logs/bundle/:bundle/range/?:day1/?:day2?' do
    bundle, day1, day2 = params[:bundle], params[:day1], params[:day2]
    data = JSON.parse(toki.bundle_log_range(bundle, day1, day2))['data']
    total = toki.helpers.calc_logs_total(data)
    name = toki.bundles[bundle]
    icon_url = icons.grab_small(name)
    erb :activity, locals: { toki: toki, title: 'Total', data: data, total: total, name: "#{bundle} - #{name} -", icon: icon_url  }
  end

  # /logs/app will be added when I find time to create an interactive page with fields, checks, apps list, etc




  # API ROUTES

  get '/api/?' do
    content_type :json
    {
      'meta' => {
        'code' => 200,
        'message' => 'Welcome to the Toki API server.'
      },
      'data' => {
        'routes' => %w{/api/apps/total /api/apps/top/[number] api/apps/day/(iso8601_date) /api/apps/range/(iso8601_date)/(iso8601_date) /api/apps/since/(iso8601_date) /api/apps/before/(iso8601_date) /api/activity /api/activity/day/(iso8601_date) /api/activity/since/(iso8601_date) /api/logs/bundle/(bundle_id)/total /api/logs/bundle/(bundle_id)/day/(iso8601_date) /api/logs/bundle/(bundle_id)/since/(iso8601_date) /api/logs/bundle/(bundle_id)/before/(iso8601_date) /api/logs/bundle/(bundle_id)/range/(iso8601_date)/(iso8601_date) /api/logs/app/(app_name)/total /api/logs/app/(app_name)/day/(iso8601_date) /api/logs/app/(app_name)/since/(iso8601_date) /api/logs/app/(app_name)/before/(iso8601_date) /api/logs/app/(app_name)/range/(iso8601_date)/(iso8601_date) /api/user /api/bundles}
      }
    }.to_json
  end

  get '/api/apps/total/?' do
    content_type :json
    toki.apps_total()
  end

  get '/api/apps/top/?:number?' do
    max = params[:number].to_i
    content_type :json
    if params[:number]
      toki.apps_top(max)
    else
      toki.apps_top()
    end
  end

  get '/api/apps/day/?:day?' do
    day = params[:day]
    content_type :json
    toki.apps_day(day)
  end

  get '/api/apps/range/:day1/?:day2?' do
    day1, day2 = params[:day1], params[:day2]
    content_type :json
    toki.apps_range(day1, day2)
  end

  get '/api/apps/since/?:day?' do
    day = params[:day]
    content_type :json
    toki.apps_since(day)
  end

  get '/api/apps/before/?:day?' do
    day = params[:day]
    content_type :json
    toki.apps_before(day)
  end

  get '/api/activity/?' do
    content_type :json
    toki.log_since()
  end

  get '/api/activity/recent/?' do
    content_type :json
    toki.log_since()
  end

  get '/api/activity/today/?' do
    content_type :json
    toki.log_since()
  end

  get '/api/activity/day/?:day?' do
    day = params[:day]
    content_type :json
    toki.log_day(day)
  end

  get '/api/activity/since/?:day?' do
    day = params[:day]
    content_type :json
    toki.log_since(day)
  end

  get '/api/logs/bundle/:bundle/total/?' do
    bundle = params[:bundle]
    content_type :json
    toki.bundle_log(bundle)
  end

  get '/api/logs/bundle/:bundle/day/?:day?' do
    bundle, day = params[:bundle], params[:day]
    content_type :json
    toki.bundle_log_day(bundle, day)
  end

  get '/api/logs/bundle/:bundle/since/?:day?' do
    bundle, day = params[:bundle], params[:day]
    content_type :json
    toki.bundle_log_since(bundle, day)
  end

  get '/api/logs/bundle/:bundle/before/?:day?' do
    bundle, day = params[:bundle], params[:day]
    content_type :json
    toki.bundle_log_before(bundle, day)
  end

  get '/api/logs/bundle/:bundle/range/?:day1/?:day2?' do
    bundle, day1, day2 = params[:bundle], params[:day1], params[:day2]
    content_type :json
    toki.bundle_log_range(bundle, day1, day2)
  end

  get '/api/logs/app/:app/total/?' do
    app = params[:app]
    content_type :json
    candidates = getters.bundles_from_name(app)
    candidates.map {|bundle| toki.bundle_log(bundle)}
  end

  get '/api/logs/app/:app/day/?:day?' do
    app, day = params[:app], params[:day]
    content_type :json
    candidates = getters.bundles_from_name(app)
    candidates.map {|bundle| toki.bundle_log_day(bundle, day)}
  end

  get '/api/logs/app/:app/since/?:day?' do
    app, day = params[:app], params[:day]
    content_type :json
    candidates = getters.bundles_from_name(app)
    candidates.map {|bundle| toki.bundle_log_since(bundle, day)}
  end

  get '/api/logs/app/:app/before/?:day?' do
    app, day = params[:app], params[:day]
    content_type :json
    candidates = getters.bundles_from_name(app)
    candidates.map {|bundle| toki.bundle_log_before(bundle, day)}
  end

  get '/api/logs/app/:app/range/?:day1/?:day2?' do
    app, day1, day2 = params[:app], params[:day1], params[:day2]
    content_type :json
    candidates = getters.bundles_from_name(app)
    candidates.map {|bundle| toki.bundle_log_range(bundle, day1, day2)}
  end

  get '/api/user/?' do
    content_type :json
    File.read(fileops.user_file)
  end

  get '/api/bundles/?' do
    content_type :json
    fileops.bundles.to_json
  end

  get '/api/names/?' do
    content_type :json
    fileops.bundles.to_json
  end

  # ---

  not_found do
    message = request.env['sinatra.error'].to_s.split('::')[1]
    if request.path_info =~ /\/api/
      content_type :json
      {
        'meta' => {
          'code' => 404,
          'message' => message,
          'processed_at' => Time.now
        },
        'data' => request.env
      }.to_json
    else
      erb :error, locals: { title: '404', data: request.env, error: message }
    end
  end

end
