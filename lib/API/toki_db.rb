# encoding: utf-8

module TokiCLI

  class TokiDB

    def initialize(db_path)
      @db = Amalgalite::Database.new(db_path)
      @table = 'KKAppActivity'
    end

    def apps_total
      @db.execute("SELECT bundleIdentifier,sum(totalSeconds) FROM #{@table} GROUP BY bundleIdentifier")
    end

  end

end
