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
  toki = TokiCLI::TokiAPI.new(fileops.db_path, fileops.bundles)
  # itunesgrabber = ItunesIcon.new

  get '/' do
    erb :index
  end

  get '/api/apps/total/?' do
    toki.apps_total
    content_type :json
    toki.response
  end

end
