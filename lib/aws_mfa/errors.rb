class AwsMfa
  class Errors

    class Error < StandardError; end
    class ConfigurationNotFound < Error; end
    class CommandNotFound < Error; end
    class DeviceNotFound < Error; end
    class InvalidCode < Error; end

  end
end
