$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'coveralls'
Coveralls.wear!

# require 'TokiCLI'
require_relative '../lib/TokiCLI'
require_relative '../lib/API/toki_api'

require 'stringio'
def capture_stdout(&blk)
  old = $stdout
  $stdout = fake = StringIO.new
  blk.call
  fake.string
ensure
  $stdout = old
end
def capture_stderr(&blk)
  old = $stderr
  $stderr = fake = StringIO.new
  blk.call
  fake.string
ensure
  $stderr = old
end
