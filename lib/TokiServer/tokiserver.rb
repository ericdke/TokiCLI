#!/usr/bin/env ruby
# encoding: utf-8

require "sinatra"
require "sinatra/assetpack"
require_relative '../API/toki_api'
require_relative '../TokiCLI/fileops'
# require_relative "itunesicon"
require "sinatra/reloader"

class TokiServer < Sinatra::Application


  # SINATRA INIT

  configure :development do
    register Sinatra::Reloader
  end

  set :server, %w[thin webrick]
  set :port, 4567
  set :root, File.dirname(__FILE__)

  assets do
    serve '/js', :from => 'js'
    serve '/bower_components', :from => 'bower_components'

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


  # TOKI INIT

  fileops = TokiCLI::FileOps.new
  toki = TokiCLI::TokiAPI.new(fileops.db_file, fileops.bundles)
  # Each toki instance has @response, which always contains the last result from a command
  # So you can go with state (updated toki.response) or stateless (create new TokiAPI instances)

  # itunesgrabber = ItunesIcon.new


  # WEB ROUTES

  # INDEX
  get '/' do
    erb :index
  end


  # API ROUTES

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
    activity_today(toki)
  end

  get '/api/activity/recent/?' do
    activity_today(toki)
  end

  get '/api/activity/today/?' do
    activity_today(toki)
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



  # METHODS

  ## API

  def activity_today(toki)
    content_type :json
    toki.log_since()
  end




end
