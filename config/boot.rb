ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# Fix for logger gem conflict - ensure built-in Logger is loaded first
require 'logger'

require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
