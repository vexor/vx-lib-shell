require 'timeout'

module Vx
  module Lib
    module Shell

      class TimeoutError < ::Timeout::Error

        def initialize(cmd, seconds)
          @cmd = cmd
          @seconds = seconds
        end

        def to_s
          "Execution expired, command did not finish within #{@seconds} seconds"
        end

      end

      class ReadTimeoutError < ::Timeout::Error

        def initialize(cmd, seconds)
          @cmd = cmd
          @seconds = seconds
        end

        def to_s
          "No output has been received in the last #{@seconds} seconds"
        end
      end

    end
  end
end
