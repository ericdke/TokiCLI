#!/usr/bin/ruby
# encoding: utf-8
#
# Grab iTunes Icon - Brett Terpstra 2014 <http://brettterpstra.com>
#
# Modified by Eric Dejonckheere for TokiCLI

%w[net/http open-uri cgi].each {|lib| require lib}

class ItunesIcons

  def initialize(fileops)
    @fileops = fileops
  end

  def grab_small(*args)
    @entity = "macSoftware"
    @icon_size = "artworkUrl60"
    grab(args)
  end

  def grab_big(*args)
    @entity = "macSoftware"
    @icon_size = "artworkUrl100"
    grab(args)
  end

  def grab(*args)
    terms = args.join(" ")
    icon_url = find_icon(terms)
    if icon_url
      URI.parse(icon_url)
    else
      ''
    end
  end

  def find_icon(terms)
    url = URI.parse("http://itunes.apple.com/search?term=#{CGI.escape(terms)}&entity=#{@entity}")
    res = Net::HTTP.get_response(url).body
    match = res.match(/"#{@icon_size}":"(.*?)",/)
    unless match.nil?
      return match[1]
    else
      return false
    end
  end

  def download url, path
    begin
      open(url) do |f|
        File.open(path,'w+') do |file|
          file.puts(f.read)
        end
      end
      true
    rescue
      false
    end
  end

end
