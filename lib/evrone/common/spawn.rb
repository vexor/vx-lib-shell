require 'timeout'
require File.expand_path("../spawn/version", __FILE__)

module Evrone
  module Common
    module Spawn

      autoload :Process,     File.expand_path("../spawn/process",      __FILE__)
      autoload :SSH,         File.expand_path("../spawn/ssh",          __FILE__)
      autoload :Timeout,     File.expand_path("../spawn/timeout",      __FILE__)
      autoload :ReadTimeout, File.expand_path("../spawn/read_timeout", __FILE__)

      class << self
        def pool_interval ; 0.1 end
      end

      def open_ssh(*args, &block)
      end

      def bash(*args, &block)
      end

      def spawn(*args, &block)
        Common::Spawn::Process.spawn(*args, &block)
      end

      class TimeoutError     < ::Timeout::Error

        def initialize(cmd, seconds)
          @cmd = cmd
          @seconds = seconds
        end

        def to_s
          "Execution of '#{@cmd}' expired"
        end

      end

      class ReadTimeoutError < ::Timeout::Error

        def initialize(cmd, seconds)
          @cmd = cmd
          @seconds = seconds
        end

        def to_s
          "No output has been received of '#{@cmd}' in the last #{@seconds} seconds"
        end
      end

    end
  end
end
