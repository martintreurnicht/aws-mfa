require 'json'

class AwsMfa
  attr_reader :aws_config_dir

  def initialize
    validate_aws_installed
    @aws_config_dir = find_aws_config
  end

  def validate_aws_installed
    abort 'Could not find the aws command' unless which('aws')
  end

  def find_aws_config
    if ENV['AWS_CREDENTIAL_FILE']
      aws_config_file = ENV['AWS_CREDENTIAL_FILE']
      aws_config_dir = File.dirname(aws_config_file)
    else
      aws_config_dir = File.join(ENV['HOME'], '.aws')
      aws_config_file = File.join(aws_config_dir, 'config')
    end

    unless File.readable?(aws_config_file)
      abort 'Aws configuration not found. You must run `aws cli configure`'
    end

    aws_config_dir
  end

  # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
  def which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each { |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable? exe
      }
    end
    return nil
  end

  def load_arn
    arn_file = File.join(aws_config_dir, 'mfa_device')

    if File.readable?(arn_file)
      arn = load_arn_from_file(arn_file)
    else
      arn = load_arn_from_aws
      write_arn_to_file(arn_file, arn)
    end

    arn
  end

  def load_arn_from_file(arn_file)
    File.read(arn_file)
  end

  def load_arn_from_aws
    puts 'Fetching MFA devices for your account...'
    mfa_devices = JSON.parse(`aws --output json iam list-mfa-devices`).fetch('MFADevices')
    if mfa_devices.any?
      mfa_devices.first.fetch('SerialNumber')
    else
      abort 'No MFA devices were found for your account'
    end
  end

  def write_arn_to_file(arn_file, arn)
    File.open(arn_file, 'w') { |f| f.print arn }
    puts "Using MFA device #{arn}. To change this in the future edit #{arn_file}."
  end

  def load_credentials(arn)
    credentials_file  = File.join(aws_config_dir, 'mfa_credentials')

    if File.readable?(credentials_file) && token_not_expired?(credentials_file)
      credentials = load_credentials_from_file(credentials_file)
    else
      credentials = load_credentials_from_aws(arn)
      write_credentials_to_file(credentials_file, credentials)
    end

    JSON.parse(credentials).fetch('Credentials')
  end

  def load_credentials_from_file(credentials_file)
    File.read(credentials_file)
  end

  def load_credentials_from_aws(arn)
    code = request_code_from_user
    unset_environment
    `aws --output json sts get-session-token --serial-number #{arn} --token-code #{code}`
  end

  def write_credentials_to_file(credentials_file, credentials)
    File.open(credentials_file, 'w') { |f| f.print credentials }
  end

  def request_code_from_user
    puts 'Enter the 6-digit code from your MFA device:'
    code = $stdin.gets.chomp
    abort 'That is an invalid MFA code' unless code =~ /^\d{6}$/
    code
  end

  def unset_environment
    ENV.delete('AWS_SECRET_ACCESS_KEY')
    ENV.delete('AWS_ACCESS_KEY_ID')
    ENV.delete('AWS_SESSION_TOKEN')
    ENV.delete('AWS_SECURITY_TOKEN')
  end

  def token_not_expired?(credentials_file)
    # default is 12 hours
    expiration_period = 12 * 60 * 60
    mtime = File.stat(credentials_file).mtime
    now = Time.new
    if now - mtime < expiration_period
      true
    else
      false
    end
  end

  def print_credentials(credentials)
    puts "export AWS_SECRET_ACCESS_KEY='#{credentials['SecretAccessKey']}'"
    puts "export AWS_ACCESS_KEY_ID='#{credentials['AccessKeyId']}'"
    puts "export AWS_SESSION_TOKEN='#{credentials['SessionToken']}'"
    puts "export AWS_SECURITY_TOKEN='#{credentials['SessionToken']}'"
  end

  def export_credentials(credentials)
    ENV['AWS_SECRET_ACCESS_KEY'] = credentials['SecretAccessKey']
    ENV['AWS_ACCESS_KEY_ID'] = credentials['AccessKeyId']
    ENV['AWS_SESSION_TOKEN'] = credentials['SessionToken']
    ENV['AWS_SECURITY_TOKEN'] = credentials['SessionToken']
  end

  def execute
    arn = load_arn
    credentials = load_credentials(arn)
    if ARGV.empty?
      print_credentials(credentials)
    else
      export_credentials(credentials)
      exec(*ARGV)
    end
  end
end
