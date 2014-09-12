# encoding: utf-8

module TokiCLI

  class Helpers

    require 'CFPropertyList'

    def sec_to_time(secs)
      begin
        hours = secs / 3600
        minutes = (secs / 60 - hours * 60)
        seconds = (secs - (minutes * 60 + hours * 3600))
        {hours: hours, minutes: minutes, seconds: seconds}
      rescue Exception => e
        oops e
      end
    end

  end

end
