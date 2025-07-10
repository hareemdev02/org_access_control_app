# Fix for logger gem conflict with ActiveSupport
# This initializer ensures the built-in Ruby Logger is used instead of the logger gem

# Force load the built-in Ruby Logger before any gems try to load the logger gem
require 'logger'

# Store the original Logger class
OriginalLogger = ::Logger

# If the logger gem has been loaded, replace it with the built-in Logger
if defined?(::Logger) && ::Logger.respond_to?(:VERSION) && ::Logger::VERSION.start_with?('1.')
  # Remove the logger gem's Logger class
  Object.send(:remove_const, :Logger)
  # Restore the original Logger
  ::Logger = OriginalLogger
end

# Ensure ActiveSupport can find the Logger
if defined?(ActiveSupport::LoggerThreadSafeLevel)
  ActiveSupport::LoggerThreadSafeLevel::Logger = ::Logger
end

# Additional fix for the specific error
if defined?(ActiveSupport::LoggerThreadSafeLevel)
  unless ActiveSupport::LoggerThreadSafeLevel.const_defined?(:Logger)
    ActiveSupport::LoggerThreadSafeLevel.const_set(:Logger, ::Logger)
  end
end 