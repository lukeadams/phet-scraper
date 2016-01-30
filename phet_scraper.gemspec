# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'phet_scraper/version'

Gem::Specification.new do |spec|
  spec.name          = "phet_scraper"
  spec.version       = PhetScraper::VERSION
  spec.authors       = ["Luke Adams"]
  spec.email         = ["luke4450@gmail.com"]

  spec.summary       = 'Simple script to scrape all PhET sims'
  spec.homepage      = "https://github.com/lukeadams/phet_scraper"
  spec.license       = "MIT"

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency 'nokogiri'
  spec.add_runtime_dependency 'retryable'
  spec.add_runtime_dependency 'mechanize'
  spec.add_runtime_dependency 'ruby-progressbar'
end
