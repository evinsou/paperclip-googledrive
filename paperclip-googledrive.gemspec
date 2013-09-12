# -*- encoding: utf-8 -*-
#require File.expand_path('../lib/paperclip_googledrive/version', __FILE__)
$:.push File.expand_path("../lib", __FILE__)
require "paperclip/version"

Gem::Specification.new do |gem|
  gem.name          = "paperclip-googledrive"
  gem.version       = PaperclipGoogleDrive::VERSION
  gem.authors       = ['evinsou']
  gem.email         = ["evinsou@gmail.com"]

  gem.summary       = %q{Extends Paperclip with Google Drive storage}
  gem.description   = %q{paperclip-googledrive extends paperclip support of storage for google drive storage}
  gem.homepage      = "https://github.com/evinsou/paperclip-googledrive"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = Dir["lib/**/*"] + ["README.md", "LICENSE", "paperclip-googledrive.gemspec"]
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  gem.require_paths = ["lib"]
  gem.required_ruby_version = ">= 1.9.2"
  gem.license       = "MIT"

  gem.add_dependency "paperclip", "~> 3.4"
  gem.add_dependency 'google-api-client', "~> 0.5"

  gem.add_development_dependency "rake", ">= 0.9"
end
