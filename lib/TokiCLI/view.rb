# encoding: utf-8

module TokiCLI

  class View

    require 'terminal-table'

    def initialize settings = {}
      @settings = if settings.empty?
        {"table"=>{"width"=>90}} # force default if no initialization
      else
        settings
      end
    end

    def version
      table = init_table("TokiCLI for Toki.app")
      table << ['Version', VERSION]
      table << :separator
      table << ['Infos', 'http://github.com/ericdke/TokiCLI']
      puts "\n#{table}\n"
    end

    def apps_total(api_response, title = "Your apps monitored by Toki")
      table, apps = make_apps_total(api_response, title)
      puts "\n"
      display, total = populate_apps_table(table, apps)
      display << :separator
      display << [{ :value => "Total: #{readable_time(sec_to_time(total))}", :colspan => 3, :alignment => :center }]
      puts display
    end

    def apps_top(api_response, title = "Your apps monitored by Toki")
      table, apps = make_apps_total(api_response, title)
      puts "\n"
      display, _ = populate_apps_table(table, apps)
      puts display
    end

    def log_table(api_response, title = "Your app monitored by Toki")
      log = JSON.parse(api_response)['data']
      table = init_table(title)
      table.headings = ['Start', 'Duration', 'Sync ID']
      lines = make_log_lines(log)
      total = total_from_log_lines(lines)
      display = populate_log_table(lines, table, total)
      puts "\nRendering the view, please wait.\n\n"
      lines = display.render
      puts "\e[H\e[2J"
      puts lines
    end

    private

    def init_table(title = 'TokiCLI')
      Terminal::Table.new do |t|
        t.style = { :width => @settings['table']['width'] }
        t.title = title
      end
    end

    def make_apps_total(api_response, title)
      apps = JSON.parse(api_response)['data']
      table = init_table(title)
      table.headings = ['Bundle ID', 'Name', 'Total']
      return table, apps
    end

    def make_log_lines(log)
      log.map { |k, v| [v['start'], readable_time_log(v['duration']['time']), k, v['duration']['seconds']] }
    end

    def total_from_log_lines(lines)
      total = 0
      lines.each { |obj| total += obj[3] }
      return total
    end

    def populate_log_table(lines, table, total)
      day = lines[0][0][0..9]
      table << [{ :value => "#{day}", :colspan => 3, :alignment => :center }]
      table << :separator
      lines.each do |line|
        new_day = line[0][0..9]
        unless day == new_day
          table << :separator
          table << [{ :value => "#{new_day}", :colspan => 3, :alignment => :center }]
          table << :separator
        end
        table << [line[0][10..18], line[1], line[2]]
        day = new_day
      end
      return table, total
    end

    def populate_apps_table(table, apps)
      total = 0
      apps.each do |app|
        total += app['total']['seconds']
        if app['name']
          table << app_row_with_name(app)
        else
          table << app_row(app)
        end
      end
      return table, total
    end

    def app_row_with_name(obj)
      max = @settings['table']['width'] / 3
      [width(max + 5, obj['bundle']), width(max - 5, obj['name']), readable_time(obj['total']['time'])]
    end

    def app_row(obj)
      max = @settings['table']['width'] / 2
      [width(max, obj['bundle']), '(unknown)', readable_time(obj['total']['time'])]
    end

    def width(width, text)
      boundary = width - 3
      text.length >= width ? "#{text[0..boundary]}..." : text
    end

    def readable_time(obj)
      "#{'%.2d' % obj['hours']}h #{'%.2d' % obj['minutes']}m #{'%.2d' % obj['seconds']}s"
    end

    def readable_time_log(obj)
      "#{'%.2d' % obj['minutes']}m #{'%.2d' % obj['seconds']}s"
    end

    def sec_to_time(secs)
      hours = secs / 3600
      minutes = (secs / 60 - hours * 60)
      seconds = (secs - (minutes * 60 + hours * 3600))
      {'hours' => hours, 'minutes' => minutes, 'seconds' => seconds}
    end

  end

end
