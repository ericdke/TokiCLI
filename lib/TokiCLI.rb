# encoding: utf-8
require 'thor'
require 'amalgalite'
require 'terminal-table'
%w{version}.each {|r| require_relative "TokiCLI/#{r}"}


module TokiCLI
  class App < Thor
    package_name "TokiCLI"
  end
end
