# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'scraper/version'

Gem::Specification.new do |spec|
  spec.name          = "phet_scraper"
  spec.version       = PhetScraper::VERSION
  spec.authors       = ["Luke Adams"]
  spec.email         = ["luke4450@gmail.com"]

  spec.summary       = 'Simple script to scrape all PhET sims'
  spec.homepage      = "https://github.com/lukeadams/phet_scraper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
end
