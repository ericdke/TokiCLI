# encoding: utf-8
module TokiCLI

  class ADNImport

    require 'rest-client'

    CLIENT_ID = 'm6AccJFM56ENCn58Vde9cSg3uSpbvAAs'
    CALLBACK_URL = 'http://aya.io/toki_cli/auth.html'

    attr_reader :token, :config

    def initialize(data_path)
      @toki_db_path = "#{Dir.home}/Library/Containers/us.kkob.Toki/Data/Documents/toki_data.sqlite3"
      @data_path = data_path
      @user_file = "#{data_path}/user.json"
      @shell = Thor::Shell::Basic.new
      @auth_url = "https://account.app.net/oauth/authenticate?client_id=#{CLIENT_ID}&response_type=token&redirect_uri=#{CALLBACK_URL}&scope=basic,messages&include_marker=1"
    end

    def restore
      please_quit()
      if File.exist? @user_file
        @shell.say_status :loading, "user infos"
        @config = JSON.parse(File.read(@user_file))
        @token = @config['token']
      else
        ask_token()
        get_user_data()
        @shell.say_status :analysing, "App.net channels"
        channel = get_channel_id()
        @shell.say_status :writing, "user file"
        File.write(@user_file, @config.merge({'channel' => channel}).to_json)
      end
      adn_data = get_messages(@config['channel'])
      @shell.say_status :writing, "App.net data file"
      File.write("#{@data_path}/adn_backup.json", adn_data.to_json)
      @shell.say_status :decoding, "App.net data file"
      lines = decode(adn_data)
      @shell.say_status :creating, "new database file"
      db = create_db()
      @shell.say_status :creating, "database table"
      create_table(db)
      @shell.say_status :populating, "database"
      populate(db, lines)
      @shell.say_status :replacing, "database file"
      replace()
      @shell.say_status :done, "Restore database from the App.net backup"
      puts "\n\nDone. You may relaunch Toki.app now.\n\n"
    end

    private

    def please_quit
      resp = @shell.yes? "\nYou need to quit Toki.app before restoring data from App.net.\n\nPlease quit Toki.app then type 'Y' to continue.\n\n>> "
      puts "\n"
      abort("\nCanceled.\n\n") if resp == false
    end

    def ask_token
      @shell.say "\nPlease click this URL, or copy/paste it in a browser:\n"
      puts "\n#{@auth_url}\n\n"
      @shell.say "then log in with your ADN credentials to authorize TokiCLI.\n\n"
      @shell.say "You will then be redirected to a page showing a 'user token'.\n\n"
      @token = @shell.ask "Copy the token then paste it here:\n\n>>"
      puts "\n"
    end

    def get_user_data
      @shell.say_status :connecting, "App.net"
      @shell.say_status :downloading, "User infos"
      resp = get_user()
      @config = {
        'username' => resp['data']['username'],
        'name' => resp['data']['name'],
        'id' => resp['data']['id'],
        'handle' => "@#{resp['data']['username']}",
        'token' => @token
      }
    end

    def get_user
      JSON.parse(RestClient.get("https://api.app.net/users/me?access_token=#{@token}", :verify_ssl => OpenSSL::SSL::VERIFY_NONE) {|response, request, result| response })
    end

    def get_channel_id
      get_channels().each do |ch|
        return ch['id'].to_i if ch['type'] == 'us.kkob.toki.sync-b'
      end
    end

    def get_channels
      args = {:count => 200, :before_id => nil}
      channels = []
      loop do
        url = "http://api.app.net/users/me/channels?access_token=#{@token}&include_machine=1&include_message_annotations=1&include_deleted=0&include_html=0&count=#{args[:count]}&before_id=#{args[:before_id]}"
        resp = JSON.parse(RestClient.get(url))
        resp['data'].each { |m| channels << m }
        break unless resp['meta']['more']
        args = {:count => 200, :before_id => resp['meta']['min_id']}
      end
      channels
    end

    def get_messages(channel_id)
      @shell.say_status :connecting, "App.net"
      @shell.say_status :downloading, "Toki infos"
      args = {:count => 200, :before_id => nil}
      @messages = []
      @index = 1
      @shell.say_status :downloading, "Toki sync objects"
      loop do
        begin
          @shell.say_status :downloading, "page #{'%.2d' % @index}"
          url = "http://api.app.net/channels/#{channel_id}/messages?access_token=#{@token}&include_machine=1&include_message_annotations=1&include_user_annotations=0&include_deleted=0&include_html=0&count=#{args[:count]}&before_id=#{args[:before_id]}"
          data = RestClient.get(url)
          resp = JSON.parse(data)
          dates = []
          resp['data'].each do |m|
            dates << m['created_at'][0..9]
            @messages << m
          end
          @shell.say_status :downloaded, "#{dates.uniq.join(', ')}"
          break unless resp['meta']['more']
          @index += 1
          args = {:count => 200, :before_id => resp['meta']['min_id']}
        rescue Interrupt
          abort(Status.canceled)
        end
      end
      @messages
    end

    def decode(adn_data)
      adn_data.map do |obj|
        {
          'type' => obj['annotations'][0]['type'],
          'table' => obj['annotations'][0]['value']['c'],
          'uuid' => obj['annotations'][0]['value']['d']['UUID'],
          'bundleIdentifier' => obj['annotations'][0]['value']['d']['bundleIdentifier'],
          'activeTo' => obj['annotations'][0]['value']['d']['activeTo'],
          'activeFrom' => obj['annotations'][0]['value']['d']['activeFrom'],
          'totalSeconds' => obj['annotations'][0]['value']['d']['totalSeconds'],
          'id' => obj['annotations'][0]['value']['d']['id']
        }
      end
    end

    def create_db
      file = "#{@data_path}/db_from_adn.sqlite3"
      File.rm(file) if File.exist?(file)
      Amalgalite::Database.new(file)
    end

    def create_table db
      db.execute_batch <<-SQL
        CREATE TABLE KKAppActivity (
          id INTEGER,
          bundleIdentifier VARCHAR(256),
          activeTo INTEGER,
          activeFrom INTEGER,
          totalSeconds INTEGER,
          UUID VARCHAR(256),
          synced INTEGER,
          availableToSync INTEGER
        );
      SQL
      db.reload_schema!
    end

    def populate(db, lines)
      before = Time.now
      @shell.say_status :processing, "#{lines.size} rows"
      db.transaction do |db_in_transaction|
        lines.each do |obj|
          insert_data = {}
          insert_data[':id'] = obj['id']
          insert_data[':bundleIdentifier'] = obj['bundleIdentifier']
          insert_data[':activeTo'] = obj['activeTo']
          insert_data[':activeFrom'] = obj['activeFrom']
          insert_data[':totalSeconds'] = obj['totalSeconds']
          insert_data[':UUID'] = obj['uuid']
          insert_data[':synced'] = 1
          insert_data[':availableToSync'] = 1

          db_in_transaction.prepare("INSERT INTO KKAppActivity(id, bundleIdentifier, activeTo, activeFrom, totalSeconds, UUID, synced, availableToSync) VALUES(:id, :bundleIdentifier, :activeTo, :activeFrom, :totalSeconds, :UUID, :synced, :availableToSync);") do |insert|
            insert.execute(insert_data)
          end

        end
      end
      @shell.say_status :finished, "insertion of #{idx} rows in #{Time.now - before} seconds"
    end

    def replace
      FileUtils.mv @toki_db_path, "#{Dir.home}/.Trash/"
      FileUtils.mv "#{@data_path}/db_from_adn.sqlite3", @toki_db_path
    end

  end

end
