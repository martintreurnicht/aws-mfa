Gem::Specification.new do |s|
  s.name         = 'aws-mfa'
  s.version      = '0.2.0'
  s.date         = '2014-09-30'
  s.description  = 'Run AWS commands with MFA'
  s.summary      = s.description
  s.authors      = ['Brian Pitts']
  s.email        = 'brian.pitts@lonelyplanet.com'
  s.files        = ['lib/aws_mfa.rb']
  s.executables  = ['aws-mfa']
  s.homepage     = 'http://www.github.com/lonelyplanet/aws-mfa'
  s.license      = 'Apache-2.0'
  s.requirements = ['aws-cli']
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'fakefs'
end
