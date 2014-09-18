require 'spec_helper'

describe TokiCLI do

  before do
    TokiCLI::FileOps.any_instance.stub(:db_file).and_return('spec/mock/mock.sqlite3')
    TokiCLI::FileOps.any_instance.stub(:bundles).and_return(nil)
  end

  describe "#version" do
    it 'has a version number' do
      expect(TokiCLI::VERSION).not_to be nil
    end
    it "shows version number" do
      printed = capture_stdout do
        TokiCLI::App.start(['version'])
      end
      expect(printed).to include 'TokiCLI'
      expect(printed).to include 'Version'
      expect(printed).to include 'github'
    end
  end

  describe "#total" do
    it "shows the total for all apps" do
      printed = capture_stdout do
        TokiCLI::App.start(['total'])
      end
      expect(printed).to include *%w{com.apple.ReportPanic com.apple.SystemProfiler com.apple.systemuiserver com.apple.InstallAssistant.OSX10Seed1 com.apple.frameworks.diskimages.diuiagent com.apple.WebKit.WebContent com.apple.coreservices.uiagent com.apple.PhotoBooth com.apple.TextEdit com.apple.ProblemReporter com.apple.FontBook com.apple.DigitalColorMeter com.apple.KeyboardSetupAssistant com.apple.ScriptEditor2 com.apple.installer com.apple.DiskUtility com.apple.ActivityMonitor com.apple.iCal com.apple.iphonesimulator com.apple.NetAuthAgent com.apple.AddressBook com.apple.Console com.apple.mail com.apple.Notes com.apple.ScreenSaver.Engine com.apple.Automator com.apple.AirPlayUIAgent com.apple.FaceTime com.apple.iPhoto com.apple.dt.Xcode com.apple.QuickTimePlayerX com.apple.iChat com.apple.systempreferences com.apple.Preview com.apple.WebKit.PluginProcess com.apple.ScreenSharing com.apple.appstore com.apple.ASApplication com.apple.Terminal com.apple.iBooksX com.apple.iTunes com.apple.finder com.apple.Safari}
    end
  end

  describe "#top" do
    it "shows the top 10 apps" do
      printed = capture_stdout do
        TokiCLI::App.start(['top', '-n10'])
      end
      expect(printed).to include *%w{com.apple.Preview com.apple.WebKit.PluginProcess com.apple.ScreenSharing com.apple.appstore com.apple.ASApplication com.apple.Terminal com.apple.iBooksX com.apple.iTunes com.apple.finder com.apple.Safari}
      expect(printed).to_not include 'com.apple.systempreferences'
    end

    it "shows the top apps" do
      printed = capture_stdout do
        TokiCLI::App.start(['top'])
      end
      expect(printed).to include *%w{com.apple.Terminal com.apple.iBooksX com.apple.iTunes com.apple.finder com.apple.Safari}
      expect(printed).to_not include 'com.apple.ASApplication'
    end
  end

  describe "day" do
    it "shows apps for day 2014-09-15" do
      printed = capture_stdout do
        TokiCLI::App.start(['day', '2014-09-15'])
      end
      expect(printed).to include *%w{com.apple.finder com.apple.Safari}
      expect(printed).to_not include 'com.apple.iTunes'
    end
  end

  describe "range" do
    it "shows apps between 2014-09-12 and 2014-09-15" do
      printed = capture_stdout do
        TokiCLI::App.start(['range', '2014-09-12', '2014-09-15'])
      end
      expect(printed).to include *%w{com.apple.NetAuthAgent com.apple.ActivityMonitor com.apple.installer com.apple.appstore com.apple.iTunes com.apple.Terminal com.apple.ScreenSaver.Engine com.apple.ScreenSharing com.apple.WebKit.PluginProcess com.apple.finder com.apple.Safari}
      expect(printed).to_not include 'com.apple.TextEdit'
    end
  end

  describe "before" do
    it "shows apps before 2014-05-15" do
      printed = capture_stdout do
        TokiCLI::App.start(['before', '2014-05-15'])
      end
      expect(printed).to include *%w{com.apple.coreservices.uiagent com.apple.ReportPanic com.apple.frameworks.diskimages.diuiagent com.apple.installer com.apple.ProblemReporter com.apple.WebKit.WebContent com.apple.dt.Xcode com.apple.TextEdit com.apple.NetAuthAgent com.apple.DigitalColorMeter com.apple.KeyboardSetupAssistant com.apple.ActivityMonitor com.apple.Automator com.apple.mail com.apple.iphonesimulator com.apple.Terminal com.apple.Console com.apple.Notes com.apple.iChat com.apple.WebKit.PluginProcess com.apple.Preview com.apple.iPhoto com.apple.ASApplication com.apple.systempreferences com.apple.ScreenSharing com.apple.appstore com.apple.QuickTimePlayerX com.apple.iTunes com.apple.finder com.apple.Safari}
    end
  end

  describe "since" do
    it "shows apps since 2014-09-12" do
      printed = capture_stdout do
        TokiCLI::App.start(['since', '2014-09-12'])
      end
      expect(printed).to include *%w{com.apple.NetAuthAgent com.apple.ActivityMonitor com.apple.installer com.apple.appstore com.apple.iTunes com.apple.Terminal com.apple.ScreenSaver.Engine com.apple.ScreenSharing com.apple.WebKit.PluginProcess com.apple.finder com.apple.Safari}
      expect(printed).to_not include 'com.apple.TextEdit'
    end
  end

  describe "activity" do
    it "shows activity for 2014-09-14" do
      printed = capture_stdout do
        TokiCLI::App.start(['activity', '--day', '2014-09-14'])
      end
      expect(printed).to include *['com.apple.finder              |  02:00:00     | 00m 04s      | 3009986780794979448', 'com.apple.Safari              |  17:00:00     | 02m 02s      | 279578532860092796', 'com.apple.finder              |  23:30:00     | 01m 37s      | 5321635596015812810']
    end
  end

  describe "activity" do
    it "shows activity since 2014-09-14" do
      printed = capture_stdout do
        TokiCLI::App.start(['activity', '--since', '2014-09-14'])
      end
      expect(printed).to include *['com.apple.finder              |  02:00:00     | 00m 04s      | 3009986780794979448', 'com.apple.Safari              |  17:00:00     | 02m 02s      | 279578532860092796', 'com.apple.finder              |  23:30:00     | 01m 37s      | 5321635596015812810', 'com.apple.finder              |  08:15:00     | 00m 29s      | 2450616761580369798', 'com.apple.Safari              |  15:00:00     | 00m 06s      | 7557789946794681026']
    end
  end

  describe "bundle" do
    it "shows log for an app" do
      printed = capture_stdout do
        TokiCLI::App.start(['bundle', 'com.apple.iTunes'])
      end
      expect(printed).to include *['2014-04-13', '16:45:00               | 01m 02s                | 93837223385103975', '2014-04-14', '09:15:00               | 00m 18s                | 9048025340952260608', '12:30:00               | 00m 27s                | 8045504996000693405', 'Total: 3h 52m 32s']
    end
  end

end

describe TokiCLI::TokiAPI do

  let(:toki) { TokiCLI::TokiAPI.new('spec/mock/mock.sqlite3', {}) }

  describe "#apps_total" do
    it "returns the total for all apps" do
      toki.apps_total
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'apps_total'
      expect(resp['data'].first['bundle']).to eq 'com.apple.ReportPanic'
      expect(resp['data'].first['total']['seconds']).to eq 4
      expect(resp['data'].first['total']['time']['hours']).to eq 0
      expect(resp['data'].first['total']['time']['minutes']).to eq 0
      expect(resp['data'].first['total']['time']['seconds']).to eq 4

      expect(resp['data'].last['bundle']).to eq 'com.apple.Safari'
      expect(resp['data'].last['total']['seconds']).to eq 958537
      expect(resp['data'].last['total']['time']['hours']).to eq 266
      expect(resp['data'].last['total']['time']['minutes']).to eq 15
      expect(resp['data'].last['total']['time']['seconds']).to eq 37
    end
  end

  describe "#apps_top" do
    it "returns top apps" do
      toki.apps_top
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'apps_top'
      expect(resp['data'].first['bundle']).to eq 'com.apple.Terminal'
      expect(resp['data'].first['total']['seconds']).to eq 7510
      expect(resp['data'].first['total']['time']['hours']).to eq 2
      expect(resp['data'].first['total']['time']['minutes']).to eq 5
      expect(resp['data'].first['total']['time']['seconds']).to eq 10

      expect(resp['data'].last['bundle']).to eq 'com.apple.Safari'
      expect(resp['data'].last['total']['seconds']).to eq 958537
      expect(resp['data'].last['total']['time']['hours']).to eq 266
      expect(resp['data'].last['total']['time']['minutes']).to eq 15
      expect(resp['data'].last['total']['time']['seconds']).to eq 37
    end

    it "returns top 10 apps" do
      toki.apps_top(10)
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'apps_top'
      expect(resp['data'].first['bundle']).to eq 'com.apple.Preview'
      expect(resp['data'].first['total']['seconds']).to eq 3123
      expect(resp['data'].first['total']['time']['hours']).to eq 0
      expect(resp['data'].first['total']['time']['minutes']).to eq 52
      expect(resp['data'].first['total']['time']['seconds']).to eq 3

      expect(resp['data'].last['bundle']).to eq 'com.apple.Safari'
      expect(resp['data'].last['total']['seconds']).to eq 958537
      expect(resp['data'].last['total']['time']['hours']).to eq 266
      expect(resp['data'].last['total']['time']['minutes']).to eq 15
      expect(resp['data'].last['total']['time']['seconds']).to eq 37
    end
  end

  describe "#apps_day" do
    it "returns apps for day 2014-09-15" do
      toki.apps_day('2014-09-15')
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'apps_day'
      expect(resp['data'].first['bundle']).to eq 'com.apple.finder'
      expect(resp['data'].first['total']['seconds']).to eq 979
      expect(resp['data'].first['total']['time']['hours']).to eq 0
      expect(resp['data'].first['total']['time']['minutes']).to eq 16
      expect(resp['data'].first['total']['time']['seconds']).to eq 19

      expect(resp['data'].last['bundle']).to eq 'com.apple.Safari'
      expect(resp['data'].last['total']['seconds']).to eq 5058
      expect(resp['data'].last['total']['time']['hours']).to eq 1
      expect(resp['data'].last['total']['time']['minutes']).to eq 24
      expect(resp['data'].last['total']['time']['seconds']).to eq 18
    end
  end

  describe "#apps_range" do
    it "returns apps between '2014-09-12' and '2014-09-15'" do
      toki.apps_range('2014-09-12', '2014-09-15')
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'apps_range'
      expect(resp['data'].first['bundle']).to eq 'com.apple.NetAuthAgent'
      expect(resp['data'].first['total']['seconds']).to eq 5
      expect(resp['data'].first['total']['time']['hours']).to eq 0
      expect(resp['data'].first['total']['time']['minutes']).to eq 0
      expect(resp['data'].first['total']['time']['seconds']).to eq 5

      expect(resp['data'].last['bundle']).to eq 'com.apple.Safari'
      expect(resp['data'].last['total']['seconds']).to eq 22017
      expect(resp['data'].last['total']['time']['hours']).to eq 6
      expect(resp['data'].last['total']['time']['minutes']).to eq 6
      expect(resp['data'].last['total']['time']['seconds']).to eq 57
    end
  end

  describe "#apps_since" do
    it "returns apps since day 2014-09-14" do
      toki.apps_since('2014-09-14')
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'apps_since'
      expect(resp['data'].first['bundle']).to eq 'com.apple.ActivityMonitor'
      expect(resp['data'].first['total']['seconds']).to eq 6
      expect(resp['data'].first['total']['time']['hours']).to eq 0
      expect(resp['data'].first['total']['time']['minutes']).to eq 0
      expect(resp['data'].first['total']['time']['seconds']).to eq 6

      expect(resp['data'].last['bundle']).to eq 'com.apple.Safari'
      expect(resp['data'].last['total']['seconds']).to eq 19902
      expect(resp['data'].last['total']['time']['hours']).to eq 5
      expect(resp['data'].last['total']['time']['minutes']).to eq 31
      expect(resp['data'].last['total']['time']['seconds']).to eq 42
    end
  end

  describe "#apps_before" do
    it "returns apps before day 2014-09-01" do
      toki.apps_before('2014-09-01')
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'apps_before'
      expect(resp['data'].first['bundle']).to eq 'com.apple.ReportPanic'
      expect(resp['data'].first['total']['seconds']).to eq 4
      expect(resp['data'].first['total']['time']['hours']).to eq 0
      expect(resp['data'].first['total']['time']['minutes']).to eq 0
      expect(resp['data'].first['total']['time']['seconds']).to eq 4

      expect(resp['data'].last['bundle']).to eq 'com.apple.Safari'
      expect(resp['data'].last['total']['seconds']).to eq 831821
      expect(resp['data'].last['total']['time']['hours']).to eq 231
      expect(resp['data'].last['total']['time']['minutes']).to eq 3
      expect(resp['data'].last['total']['time']['seconds']).to eq 41
    end
  end

  describe "#bundle_log" do
    it "returns log for com.apple.finder" do
      toki.bundle_log('com.apple.finder')
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'bundle_log'
      expect(resp['data'].size).to eq 1397
      expect(resp['data']['6853206097451538432'].to_a).to eq [["bundle", "com.apple.finder"], ["name", nil], ["start", "2014-04-12 15:15:00 +0200"], ["duration", {"seconds"=>10, "time"=>{"hours"=>0, "minutes"=>0, "seconds"=>10}}]]
      expect(resp['data']['8223841650221385607'].to_a).to eq [["bundle", "com.apple.finder"], ["name", nil], ["start", "2014-09-15 10:45:00 +0200"], ["duration", {"seconds"=>70, "time"=>{"hours"=>0, "minutes"=>1, "seconds"=>10}}]]
    end
  end

  describe "#bundle_log_since" do
    it "returns log for com.apple.finder since 2014-09-01" do
      toki.bundle_log_since('com.apple.finder', '2014-09-01')
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'bundle_log_since'
      expect(resp['data'].size).to eq 131
      expect(resp['data']['3343489613556420396'].to_a).to eq [["bundle", "com.apple.finder"], ["name", nil], ["start", "2014-09-01 08:45:00 +0200"], ["duration", {"seconds"=>15, "time"=>{"hours"=>0, "minutes"=>0, "seconds"=>15}}]]
      expect(resp['data']['8223841650221385607'].to_a).to eq [["bundle", "com.apple.finder"], ["name", nil], ["start", "2014-09-15 10:45:00 +0200"], ["duration", {"seconds"=>70, "time"=>{"hours"=>0, "minutes"=>1, "seconds"=>10}}]]
    end
  end

  describe "#bundle_log_before" do
    it "returns log for com.apple.finder before 2014-09-01" do
      toki.bundle_log_before('com.apple.finder', '2014-09-01')
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'bundle_log_before'
      expect(resp['data'].size).to eq 1266
      arr = resp['data'].to_a
      expect(arr.first).to eq ["6853206097451538432", {"bundle"=>"com.apple.finder", "name"=>nil, "start"=>"2014-04-12 15:15:00 +0200", "duration"=>{"seconds"=>10, "time"=>{"hours"=>0, "minutes"=>0, "seconds"=>10}}}]
      expect(arr.last).to eq ["3110227595022506229", {"bundle"=>"com.apple.finder", "name"=>nil, "start"=>"2014-08-31 23:00:00 +0200", "duration"=>{"seconds"=>30, "time"=>{"hours"=>0, "minutes"=>0, "seconds"=>30}}}]
    end
  end

  describe "#bundle_log_range" do
    it "returns log for com.apple.finder between 2014-09-01 and 2014-09-04" do
      toki.bundle_log_range('com.apple.finder', '2014-09-01', '2014-09-04')
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'bundle_log_range'
      expect(resp['data'].size).to eq 26
      arr = resp['data'].to_a
      expect(arr.first).to eq ["3343489613556420396", {"bundle"=>"com.apple.finder", "name"=>nil, "start"=>"2014-09-01 08:45:00 +0200", "duration"=>{"seconds"=>15, "time"=>{"hours"=>0, "minutes"=>0, "seconds"=>15}}}]
      expect(arr.last).to eq ["249678006045203865", {"bundle"=>"com.apple.finder", "name"=>nil, "start"=>"2014-09-03 21:30:00 +0200", "duration"=>{"seconds"=>16, "time"=>{"hours"=>0, "minutes"=>0, "seconds"=>16}}}]
    end
  end

  describe "#bundle_log_day" do
    it "returns log for com.apple.finder for 2014-09-01" do
      toki.bundle_log_day('com.apple.finder', '2014-09-01')
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'bundle_log_range'
      expect(resp['meta']['request']['args']).to eq ["com.apple.finder", "2014-09-01", "2014-09-02"]
      expect(resp['data'].size).to eq 13
      arr = resp['data'].to_a
      expect(arr.first).to eq ["3343489613556420396", {"bundle"=>"com.apple.finder", "name"=>nil, "start"=>"2014-09-01 08:45:00 +0200", "duration"=>{"seconds"=>15, "time"=>{"hours"=>0, "minutes"=>0, "seconds"=>15}}}]
      expect(arr.last).to eq ["8777542996540152763", {"bundle"=>"com.apple.finder", "name"=>nil, "start"=>"2014-09-01 21:45:00 +0200", "duration"=>{"seconds"=>61, "time"=>{"hours"=>0, "minutes"=>1, "seconds"=>1}}}]
    end
  end

  describe "#log_since" do
    it "returns log for recent activity" do
      toki.log_since('2014-09-13')
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'log_since'
      expect(resp['meta']['request']['args']).to eq ["2014-09-13"]
      expect(resp['data'].size).to eq 87
      arr = resp['data'].to_a
      expect(arr.first).to eq ["1226267152535471391", {"bundle"=>"com.apple.appstore", "name"=>nil, "start"=>"2014-09-13 10:15:00 +0200", "duration"=>{"seconds"=>3, "time"=>{"hours"=>0, "minutes"=>0, "seconds"=>3}}}]
      expect(arr.last).to eq ["7557789946794681026", {"bundle"=>"com.apple.Safari", "name"=>nil, "start"=>"2014-09-15 15:00:00 +0200", "duration"=>{"seconds"=>6, "time"=>{"hours"=>0, "minutes"=>0, "seconds"=>6}}}]
    end
  end

  describe "#log_day" do
    it "returns log for '2014-09-13'" do
      toki.log_day('2014-09-13')
      resp = JSON.parse(toki.response)
      expect(resp['meta']['code']).to eq 200
      expect(resp['meta']['request']['command']).to eq 'log_range'
      expect(resp['meta']['request']['args']).to eq ["2014-09-13"]
      expect(resp['data'].size).to eq 17
      arr = resp['data'].to_a
      expect(arr.first).to eq ["6362298701774470696", {"bundle"=>"com.apple.Safari", "name"=>nil, "start"=>"2014-09-13 10:15:00 +0200", "duration"=>{"seconds"=>54, "time"=>{"hours"=>0, "minutes"=>0, "seconds"=>54}}}]
      expect(arr.last).to eq ["2496889557830869773", {"bundle"=>"com.apple.finder", "name"=>nil, "start"=>"2014-09-13 19:00:00 +0200", "duration"=>{"seconds"=>297, "time"=>{"hours"=>0, "minutes"=>4, "seconds"=>57}}}]
    end
  end


end
