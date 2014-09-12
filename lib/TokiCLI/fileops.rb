# encoding: utf-8
module TokiCLI
  class FileOps

    require 'fileutils'
    require 'CFPropertyList'

    attr_accessor :toki_path, :db_path, :bundles

    def initialize
      @home_path = Dir.home
      @toki_path = "#{@home_path}/.TokiCLI"
      @db_path = "#{@home_path}/Library/Containers/us.kkob.Toki/Data/Documents/toki_data.sqlite3"
      @bundles = load_bundles()
    end

    def backup_db
      make_toki_dir()
      if File.exist?(@db_path)
        FileUtils.copy(@db_path, "#{@toki_path}/backup/toki_data.sqlite3.bak")
      else
        raise "File does not exist: #{@db_path}"
      end
    end

    def make_toki_dir
      FileUtils.mkdir_p(@toki_path) unless Dir.exist?(@toki_path)
      FileUtils.mkdir("#{@toki_path}/backup") unless Dir.exist?("#{@toki_path}/backup")
      FileUtils.mkdir("#{@toki_path}/data") unless Dir.exist?("#{@toki_path}/data")
      FileUtils.mkdir("#{@toki_path}/config") unless Dir.exist?("#{@toki_path}/config")
    end

    def load_bundles
      bundles_file = "#{@toki_path}/data/bundles.json"
      if File.exist?(bundles_file)
        JSON.parse(File.read(bundles_file))
      else
        nil
      end
    end

    def scan_bundles
      bundle_ids = get_bundle_ids()

      puts bundle_ids.inspect
    end

    private

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
        '2BUA8C4S2C.com.agilebits.onepassword-osx-helper' => '1Password Helper'
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
