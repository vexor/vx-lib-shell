require 'timeout'

module Evrone
  module Common
    module Spawn

      class TimeoutError < ::Timeout::Error

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
