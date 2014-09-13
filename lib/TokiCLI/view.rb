# encoding: utf-8

module TokiCLI

  class View

    require 'terminal-table'

    def version
      table = init_table("TokiCLI for Toki.app")
      table << ['Version', VERSION]
      table << :separator
      table << ['Infos', 'http://github.com/ericdke/TokiCLI']
      puts "\n#{table}\n"
    end

    def apps_total(api_response, title = "Your apps monitored by Toki")
      apps = JSON.parse(api_response)['data']
      table = init_table(title)
      puts "\n"
      puts populate_apps_table(apps, table)
    end

    def log_table(api_response, title = "Your app monitored by Toki")
      log = JSON.parse(api_response)['data']
      table = init_table(title)
      table.headings = ['Start', 'Duration', 'Sync ID']
      lines = make_log_lines(log)
      total =total_from_log_lines(lines)
      puts "\nPlease wait while generating the results table...\n\n"
      puts populate_log_table(lines, table, total)
    end

    private

    def init_table(title = 'TokiCLI')
      Terminal::Table.new do |t|
        t.style = { :width => 90 }
        t.title = title
      end
    end

    def make_log_lines(log)
      log.map { |k, v| [v['start'], readable_time(v['duration']['time']), k, v['duration']['seconds']] }
    end

    def total_from_log_lines(lines)
      total = 0
      lines.each { |obj| total += obj[3] }
      return total
    end

    def populate_log_table(lines, table, total)
      lines.each { |line| table << [line[0], line[1], line[2]] }
      table << :separator
      table << [{ :value => "Total: #{readable_time(sec_to_time(total))}", :colspan => 3, :alignment => :center }]
      return table
    end

    def populate_apps_table(apps, table)
      apps.each do |app|
        if app['name']
          table << app_row_with_name(app)
        else
          table << app_row(app)
        end
      end
      return table
    end

    def app_row_with_name(obj)
      [width(30, obj['bundle']), width(30, obj['name']), readable_time(obj['total']['time'])]
    end

    def app_row(obj)
      [width(30, obj['bundle']), '(unknown)', readable_time(obj['total']['time'])]
    end

    def width(width, text)
      boundary = width - 3
      text.length >= width ? "#{text[0..boundary]}..." : text
    end

    def readable_time(obj)
      "#{'%.2d' % obj['hours']}h #{'%.2d' % obj['minutes']}m #{'%.2d' % obj['seconds']}s"
    end

    def sec_to_time(secs)
      begin
        hours = secs / 3600
        minutes = (secs / 60 - hours * 60)
        seconds = (secs - (minutes * 60 + hours * 3600))
        {'hours' => hours, 'minutes' => minutes, 'seconds' => seconds}
      end
    end

  end

end
