
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gitrepo/status/version'

Gem::Specification.new do |spec|
  spec.name          = 'gitrepo-status'
  spec.version       = Gitrepo::Status::VERSION
  spec.authors       = ['Stefan - Zipkid - Goethals']
  spec.email         = ['stefan@zipkid.eu']

  spec.summary       = 'Gitrepo status checker'
  spec.description   = 'Check status of a gitrepo compared to upstream and other source urls'
  spec.homepage      = 'https://github.com/vrtdev/gitrepo-status'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.7'

  # Building rugged is a pain, install system package 'ruby-rugged' instead.
  # spec.add_runtime_dependency 'rugged'
  spec.add_runtime_dependency 'awesome_print'
end
