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
          select_timeout = options.delete(:select_timeout) || 0.75
          timeout_error  = false
          time_end       = (timeout.to_i > 0) ? Time.now + timeout : nil

          r,w = IO.pipe
          r.sync = true

          pid = ::Process.spawn(env, cmd, options.merge(out: w, err: w))
          w.close

          loop do
            rs, _, _ = IO.select([r], nil, nil, select_timeout)

            if rs
              break if rs[0].eof?
              yield rs[0].readpartial(8192)
            end

            if time_end && Time.now > time_end
              timeout_error = true
              break
            end
          end

          ::Process.kill 'KILL', pid
          _, status = ::Process.wait2(pid) # protect from zombies

          termsig   = status.termsig
          exit_code = status.exitstatus

          timeout_error ?
            raise(TimeoutError, "#{cmd} execution expired") :
            exit_code || (termsig && termsig * -1)
        end

        class TimeoutError < ::Timeout::Error ; end
        class ReadTimeoutError < TimeoutError ; end

      end
    end
  end
end
