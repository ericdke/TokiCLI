# encoding: utf-8
module TokiCLI
  class FileOps

    require 'fileutils'
    require 'CFPropertyList'
    require 'yaml'

    attr_accessor :home_path, :toki_path, :db_path, :db_file, :bundles_file, :bundles, :config_file, :config_path, :config, :data_path, :files_path, :user_file

    def initialize
      @home_path = Dir.home
      @toki_path = "#{@home_path}/.TokiCLI"
      @data_path = "#{@toki_path}/data"
      @config_path = "#{@toki_path}/config"
      @files_path = "#{@toki_path}/files"
      @backup_path = "#{@toki_path}/backup"
      @db_path = "#{@home_path}/Library/Containers/us.kkob.Toki/Data/Documents"
      @db_file = "#{@db_path}/toki_data.sqlite3"
      @bundles_file = "#{@files_path}/bundles.json"
      @config_file = "#{@config_path}/config.yml"
      @user_file = "#{@data_path}/user.json"
      make_toki_dirs()
      @bundles = load_bundles()
      @config = create_config()
    end

    def backup_db
      FileUtils.copy(@db_file, "#{@backup_path}/toki_data.sqlite3.bak")
    end

    def load_bundles
      if File.exist?(@bundles_file)
        JSON.parse(File.read(@bundles_file))
      else
        nil
      end
    end

    def save_bundles
      @bundles = get_bundle_ids()
      File.write(@bundles_file, @bundles.to_json)
    end

    def get_bundle_from_name(name)
      app_name = name.map {|n| n.downcase}.join(' ')
      candidates = []
      @bundles.each do |bundle_id, bundle_name|
        if bundle_name.downcase =~ /#{app_name}/
          candidates << bundle_id
        end
      end
      return candidates
    end

    def export(toki, options, title = nil)
      response = JSON.parse(toki.response)
      type = response['meta']['request']['type']
      prefix = response['meta']['request']['processed_at'][0..9]
      path = if title.nil?
        "#{@data_path}/#{prefix}_#{type}"
      else
        "#{@data_path}/#{prefix}_#{type}_#{title.tr_s(' ', '-')}"
      end
      if options[:json]
        file = "#{path}.json"
        File.write(file, toki.response)
      elsif options[:csv]
        file = "#{path}.csv"
        if type == 'apps'
          export_apps_csv(response, file)
        elsif type == 'log'
          export_log_csv(response, file)
        end
      else
        abort(Status.wtf)
      end
      puts Status.file_saved(file)
    end

    private

    def export_apps_csv(response, file)
      CSV.open(file, "wb") do |csv|
        csv << ['Bundle', 'Name', 'Total', 'Hours', 'Minutes', 'Seconds']
        response['data'].each do |line|
          csv << [line['bundle'], line['name'], line['total']['seconds'], line['total']['time']['hours'], line['total']['time']['minutes'], line['total']['time']['seconds']]
        end
      end
    end

    def export_log_csv(response, file)
      CSV.open(file, "wb") do |csv|
        csv << ['Start', 'Duration (seconds)', 'Minutes', 'Seconds', 'Sync ID']
        response['data'].each {|line| csv << [line[1]['start'], line[1]['duration']['seconds'], line[1]['duration']['time']['minutes'], line[1]['duration']['time']['seconds'], line[0]]}
      end
    end

    def make_toki_dirs
      %w{backup data files config}.each do |dir|
        path = "#{@toki_path}/#{dir}"
        FileUtils.mkdir_p(path) unless Dir.exist?(path)
      end
    end

    def create_config
      return YAML.load(File.read(@config_file)) if File.exist?(@config_file)
      settings = {
        'table' => {
          'width' => 90
        }
      }
      File.write(@config_file, settings.to_yaml)
      return YAML.load(File.read(@config_file))
    end

    # Scan for names from bundle ids
    def get_bundle_ids
      @names = {}
      get_bundles(get_plists("/Applications/*/Contents/*"))
      get_bundles(get_plists("/Applications/Utilities/*/Contents/*"))
      get_bundles(get_plists("#{@home_path}/Applications/*/Contents/*"))
      specials = {
        'com.evernote.EvernoteHelper' => 'Evernote Helper',
        'com.apple.finder' => 'Finder',
        'com.apple.ReportPanic' => 'Kernel Panic',
        'com.apple.coreservices.uiagent' => 'CoreServices UIAgent',
        'com.apple.installer' => 'Apple Installer',
        'com.apple.frameworks.diskimages.diuiagent' => 'Apple Disk Images Agent',
        'com.mediaatelier.CheatSheet' => 'Cheat Sheet',
        'com.vyprvpn.authorization' => 'VyprVPN',
        'com.apple.WebKit.WebContent' => 'Safari module',
        'com.apple.ProblemReporter' => 'Apple Problem Reporter',
        'org.andymatuschak.sparkle.finish-installation' => 'Sparkle Install',
        'com.noodlesoft.HazelHelper' => 'Hazel Helper',
        'de.appsolute.MAMP' => 'MAMP',
        'com.apple.KeyboardSetupAssistant' => 'Apple Keyboard Setup Assistant',
        'com.apple.NetAuthAgent' => 'Apple Net Auth Agent',
        'com.adobe.acc.AdobeCreativeCloud' => 'Adobe Creative Cloud',
        'com.apple.iphonesimulator' => 'Apple iPhone Simulator',
        'com.macromates.TextMate.preview' => 'TextMate',
        'com.alfredapp.Alfred' => 'Alfred',
        'com.runningwithcrayons.Alfred-Preferences' => 'Alfred Preferences',
        'com.apple.WebKit.PluginProcess' => 'Safari Plugin',
        'com.apple.ScreenSharing' => 'Apple Screen Sharing',
        'org.virtualbox.app.VirtualBoxVM' => 'VirtualBox',
        '2BUA8C4S2C.com.agilebits.onepassword-osx-helper' => '1Password Helper',
        'com.apple.AirPlayUIAgent' => 'AirPlayUIAgent',
        'com.apple.ScreenSaver.Engine' => 'ScreenSaver',
        'com.adobe.PDApp' => 'Adobe Application Manager',
        'com.screentime.flash.builder' => 'Screentime for Flash',
        'com.apple.systemuiserver' => 'SystemUIServer',
        'org.mozilla.plugincontainer' => 'Mozilla Plugin-container',
        'com.adobe.ACCC.Uninstaller' => 'Adobe Creative Cloud Uninstaller',
        'com.smileonmymac.textexpander' => 'TextExpander',
        'org.pqrs.Karabiner-AXNotifier' => 'Karabiner Notifier',
        'com.apple.DiskImageMounter' => 'Apple Disk Image Mounter'
      }
      specials.each { |k, v| @names[k] = v }
      return @names
    end

    def get_plists path
      Dir.glob(path).select {|f| (File.split f).last == 'Info.plist'}
    end

    def get_bundles plists
      plists.each do |obj|
        puts Status.analysing(obj)
        begin
          pl = CFPropertyList::List.new(:file => obj)
        rescue CFFormatError, NoMethodError
          puts Status.no_plist
          next
        end
        data = CFPropertyList.native_types(pl.value)
        name = data['CFBundleName'] || data['CFBundleExecutable']
        next if name.nil?
        bundle_id = data['CFBundleIdentifier']
        next if bundle_id.nil? || bundle_id.empty?
        @names[bundle_id] = name
      end
    end

  end
end
