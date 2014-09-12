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
      puts populate_table(apps, table)
    end

    private

    def init_table(title = 'TokiCLI')
      Terminal::Table.new do |t|
        t.style = { :width => 90 }
        t.title = title
      end
    end

    def populate_table(apps, table)
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
      [width(30, obj['bundle']), width(30, obj['name']), readable_time(obj)]
    end

    def app_row(obj)
      [width(30, obj['bundle']), '(unknown)', readable_time(obj)]
    end

    def width(width, text)
      boundary = width - 3
      text.length >= width ? "#{text[0..boundary]}..." : text
    end

    def readable_time(obj)
      data = obj['total']['time']
      "#{'%.2d' % data['hours']}h #{'%.2d' % data['minutes']}m #{'%.2d' % data['seconds']}s"
    end

  end

end
