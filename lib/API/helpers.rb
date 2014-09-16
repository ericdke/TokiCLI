# encoding: utf-8

module TokiCLI

  class Helpers

    def sec_to_time(secs)
      begin
        hours = secs / 3600
        minutes = (secs / 60 - hours * 60)
        seconds = (secs - (minutes * 60 + hours * 3600))
        {'hours' => hours, 'minutes' => minutes, 'seconds' => seconds}
      rescue Exception => e
        raise e, Status.wtf
      end
    end

    def epoch_to_date(epoch)
      Time.at(epoch).to_time
    end

    def check_date_validity(day)
      begin
        DateTime.strptime(day, '%Y-%m-%d')
      rescue ArgumentError, TypeError => e
        false
      end
    end

    def readable_time(obj)
      "#{obj['hours']}h #{'%.2d' % obj['minutes']}m #{'%.2d' % obj['seconds']}s"
    end

    def readable_time_log(obj)
      "#{'%.2d' % obj['minutes']}m #{'%.2d' % obj['seconds']}s"
    end

  end

end
