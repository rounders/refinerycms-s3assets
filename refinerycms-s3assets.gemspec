# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "refinerycms-s3assets/version"

Gem::Specification.new do |s|
  s.name        = "refinerycms-s3assets"
  s.version     = Refinery::S3assets::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Francois Harbec"]
  s.email       = ["fharbec@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{copies s3 assets from production refinerycms app hosted on Heroku to local}
  s.description = %q{copies s3 assets from production refinerycms app hosted on Heroku to local}

  s.add_dependency("aws-s3", "~> 0.6.2")
  s.add_dependency("heroku", "~> 2.19.1")
  s.add_dependency("progress_bar", "~> 0.3.4")

  s.rubyforge_project = "refinerycms-s3assets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
