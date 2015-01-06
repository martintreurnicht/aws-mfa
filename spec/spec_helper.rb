require 'simplecov'
SimpleCov.start

require 'rspec'
require 'fakefs/spec_helpers'
require_relative '../lib/aws_mfa'

def create_aws_binary
  FileUtils.mkdir('/bin')
  File.new('/bin/aws', 'w')
  FileUtils.chmod(0755, '/bin/aws')
end

def create_aws_config(d = '/home/.aws')
  FileUtils.mkdir_p(d)
  File.new("#{d}/config", 'w')
end

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.warnings = false
  config.order = :random
end
