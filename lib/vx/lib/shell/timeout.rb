module Vx
  module Lib
    module Shell
      class Timeout
        def initialize(value)
          @value = (value.to_f > 0) ? value.to_f : nil
          if @value
            @time_end = Time.now + @value
          end
          @happened = false
        end

        def happened?
          return false unless @value
          return true if @happened

          @happened = Time.now > @time_end
        end

        def value
          @value
        end
      end
    end
  end
end
