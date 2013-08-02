require File.expand_path("../spawn/version", __FILE__)

module Evrone
  module Common
    module Spawn

      autoload :Process, File.expand_path("../spawn/process", __FILE__)
      autoload :SSH,     File.expand_path("../spawn/ssh",     __FILE__)

      def open_ssh(*args, &block)
      end

      def bash(*args, &block)
      end

      def spawn(*args, &block)
        Common::Spawn::Process.spawn(*args, &block)
      end

    end
  end
end
