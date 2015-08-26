# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dockerhelper/version'

Gem::Specification.new do |spec|
  spec.name          = "dockerhelper"
  spec.version       = Dockerhelper::VERSION
  spec.authors       = ["Josh McDade"]
  spec.email         = ["josh.ncsu@gmail.com"]

  spec.summary       = %q{Docker and Kubernetes helper tasks}
  spec.description   = %q{
    This project was mainly created to automate the build, tag, and push
    process of docker via rake tasks and reuse these across multiple projects.
    It also provides tasks for generating Kubernetes replication controllers,
    creating them in Kubernetes, and running rolling-update on Kubernetes.

    I recognize the code is not high quality and I expect there are many bugs.
    Hell, there are no unit tests!

    Use with extreme caution! This gem is currently in active development with a high
    risk of breaking changes every release (hence a <1 version).
  }

  spec.homepage      = "https://github.com/joshm1/dockerhelper"
  spec.licenses      = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
