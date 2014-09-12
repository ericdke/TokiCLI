# encoding: utf-8

module TokiCLI

  class View

    require 'terminal-table'

    def version
      table = init_table()
      table.title = "TokiCLI for Toki.app"
      table << ['Version', VERSION]
      table << :separator
      table << ['Infos', 'http://github.com/ericdke/TokiCLI']
      puts "\n#{table}\n"
    end

    def apps_total(data) # accepts json
      # table = init_table()
      # if data['data']['apps']
      #   if data['data']['date']
      #     table.title = "Your apps monitored by Toki: #{data['data']['date']}"
      #   else
      #     table.title = "Your apps monitored by Toki"
      #   end
      #   puts apps_3(data, table)
      # else
      #   table.title = "Your app monitored by Toki"
      #   puts total_3(data, table)
      # end
      # puts "\n"
      puts data
    end

    private

    def init_table
      Terminal::Table.new do |t|
        t.style = { :width => 80 }
      end
    end

    def max_width(width, txt)
      boundary = width - 3
      text.length >= width ? "#{text[0..boundary]}..." : text
    end

  end

end
