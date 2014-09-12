require 'spec_helper'

describe TokiCLI do
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
end
