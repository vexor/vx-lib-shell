require File.expand_path("../shell/version", __FILE__)

module Vx
  module Lib
    module Shell

      autoload :Process,          File.expand_path("../shell/process",      __FILE__)
      autoload :SSH,              File.expand_path("../shell/ssh",          __FILE__)
      autoload :Docker,           File.expand_path("../shell/docker",       __FILE__)
      autoload :Timeout,          File.expand_path("../shell/timeout",      __FILE__)
      autoload :ReadTimeout,      File.expand_path("../shell/read_timeout", __FILE__)
      autoload :TimeoutError,     File.expand_path("../shell/error",        __FILE__)
      autoload :ReadTimeoutError, File.expand_path("../shell/error",        __FILE__)

      class << self
        @@pool_interval = 1.0

        def pool_interval
          @@pool_interval
        end

        def pool_interval=(val)
          @@pool_interval = val
        end
      end

      def open_ssh(*args, &block)
        Lib::Shell::SSH.open(*args, &block)
      end

      def sh(*args)
        case args.first
        when :ssh
          args.shift
          Shell::SSH.new(*args)
        else
          Shell::Process.new
        end
      end

      def spawn(*args, &block)
        Lib::Shell::Process.spawn(*args, &block)
      end

    end
  end
end
