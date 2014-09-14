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

    # Get the log for an app given its exact bundle identifier
    def bundle_log(bundle_id)
       @db.execute("SELECT * FROM #{@table} WHERE bundleIdentifier IS '#{bundle_id}'")
    end
    def bundle_log_since(bundle_id, starting)
       @db.execute("SELECT * FROM #{@table} WHERE bundleIdentifier IS '#{bundle_id}' AND activeFrom >= #{starting}")
    end
    def bundle_log_before(bundle_id, date)
       @db.execute("SELECT * FROM #{@table} WHERE bundleIdentifier IS '#{bundle_id}' AND activeFrom < #{date}")
    end
    def bundle_log_range(bundle_id, starting, ending)
       @db.execute("SELECT * FROM #{@table} WHERE bundleIdentifier IS '#{bundle_id}' AND activeFrom >= #{starting} AND activeFrom < #{ending}")
    end

    # Get the total time for an app given its exact bundle identifier, since a specific day
    def bundle_total_since(bundle_id, starting)
      @db.execute("SELECT sum(totalSeconds) FROM #{@table} WHERE bundleIdentifier IS '#{bundle_id}' AND activeFrom >= #{starting}")
    end

    # Get the total time for an app given its exact bundle identifier, before a specific day
    def bundle_total_before(bundle_id, ending)
      @db.execute("SELECT sum(totalSeconds) FROM #{@table} WHERE bundleIdentifier IS '#{bundle_id}' AND activeFrom < #{ending}")
    end

  end

end
