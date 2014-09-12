# encoding: utf-8

module TokiCLI

  class View

    require 'terminal-table'

    # def initialize

    # end

    def apps_total(data)
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
      require 'pp'
      pp data
    end

    private

    def init_table
      Terminal::Table.new do |t|
        t.style = { :width => 75 }
      end
    end

  end

end
