# coding: utf-8
Gem::Specification.new do |gem|
  gem.name          = 'virtex'
  gem.version       = '1.0.0'
  gem.authors       = ["Zaratan", "aianus"]
  gem.email         = ["hire@alexianus.com"]
  gem.summary       = %q{A thin wrapper around the CaVirtex API}
  gem.description   = %q{A thin wrapper around the CaVirtex API}
  gem.homepage      = "https://github.com/aianus/virtex"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'httparty', '~> 0.8'
  gem.add_dependency 'multi_json', '~> 1.3'
  gem.add_dependency 'money', '~> 6.0'
  gem.add_dependency 'monetize', '~> 0.3.0'
  gem.add_dependency 'hashie', '~> 1.2.0'

  gem.add_development_dependency 'vcr', '~> 2.9'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'webmock', '~> 1.18'
  gem.add_development_dependency 'simplecov', '~> 0.7'
end
