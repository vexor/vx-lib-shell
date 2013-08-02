module Evrone
  module Common
    module Spawn
      class ReadTimeout

        def initialize(val)
          @value    = val.to_f > 0 ? val.to_f : nil
          @happened = false
        end

        def reset
          @tm = Time.new if @value
        end

        def happened?
          return true if @happened
          return false unless @tm

          @happened = Time.now > (@tm + @value)
        end

        def value
          @value
        end

      end
    end
  end
end
