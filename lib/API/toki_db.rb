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

    def apps_range(starting, ending)
      @db.execute("SELECT bundleIdentifier,sum(totalSeconds) FROM #{@table} WHERE activeFrom >= #{starting} AND activeFrom < #{ending} GROUP BY bundleIdentifier")
    end

    def apps_since(day)
      @db.execute("SELECT bundleIdentifier,sum(totalSeconds) FROM #{@table} WHERE activeFrom >= #{day} GROUP BY bundleIdentifier")
    end

    def apps_before(day)
      @db.execute("SELECT bundleIdentifier,sum(totalSeconds) FROM #{@table} WHERE activeFrom < #{day} GROUP BY bundleIdentifier")
    end

  end

end
