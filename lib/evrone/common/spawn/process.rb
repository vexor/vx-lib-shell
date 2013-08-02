require 'timeout'

module Evrone
  module Common
    module Spawn
      module Process

        extend self

        def spawn(*args)
          env     = args.first.is_a?(Hash) ? args.shift : {}
          options = args.last.is_a?(Hash)  ? args.pop   : {}
          cmd     = args.join(" ")

          timeout        = options.delete(:timeout)
          select_timeout = options.delete(:select_timeout) || Spawn.pool_interval
          timeout_error  = false
          time_end       = (timeout.to_f > 0) ? Time.now + timeout.to_f : nil

          read_timeout   = Spawn::ReadTimeout.new options.delete(:read_timeout)

          r,w = IO.pipe
          r.sync = true

          pid = ::Process.spawn(env, cmd, options.merge(out: w, err: w))
          w.close

          read_timeout.reset
          loop do
            rs, _, _ = IO.select([r], nil, nil, select_timeout)

            if !rs && read_timeout.happened?
              timeout_error = :read_timeout
              break
            end

            if rs
              break if rs[0].eof?
              yield rs[0].readpartial(8192)
              read_timeout.reset
            end

            if time_end && Time.now > time_end
              timeout_error = :timeout
              break
            end
          end

          ::Process.kill 'KILL', pid
          _, status = ::Process.wait2(pid) # protect from zombies

          case timeout_error
          when :read_timeout
            raise Spawn::ReadTimeoutError.new cmd, read_timeout.value
          when :timeout
            raise Spawn::TimeoutError.new cmd, timeout
          else
            termsig   = status.termsig
            exit_code = status.exitstatus

            exit_code || (termsig && termsig * -1)
          end

        end

      end
    end
  end
end
