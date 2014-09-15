#!/usr/bin/env ruby
# encoding: utf-8

require "sinatra"
require "sinatra/assetpack"
require_relative '../API/toki_api'
require_relative '../TokiCLI/fileops'
# require_relative "itunesicon"

class TokiServer < Sinatra::Application

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

  fileops = TokiCLI::FileOps.new
  toki = TokiCLI::TokiAPI.new(fileops.db_file, fileops.bundles)
  # Each toki instance has @response, which always contains the last result from a command
  # So you can go with state (updated toki.response) or stateless (create new TokiAPI instances)

  # itunesgrabber = ItunesIcon.new

  # INDEX
  get '/' do
    erb :index
  end

  # WEB ROUTES


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

  get '/api/apps/day/:day' do
    day = params[:day]
    content_type :json
    toki.apps_day(day)
  end



end
