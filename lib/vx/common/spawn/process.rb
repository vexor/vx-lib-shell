require 'timeout'

module Vx
  module Common
    module Spawn
      module Process

        extend self

        def spawn(*args, &block)
          env     = args.first.is_a?(Hash) ? args.shift : {}
          options = args.last.is_a?(Hash)  ? args.pop   : {}
          cmd     = args.join(" ")

          select_timeout = options.delete(:pool_interval) || Spawn.pool_interval
          timeout        = Spawn::Timeout.new options.delete(:timeout)
          read_timeout   = Spawn::ReadTimeout.new options.delete(:read_timeout)

          r,w = IO.pipe
          r.sync = true

          pid = ::Process.spawn(env, cmd, options.merge(out: w, err: w))
          w.close

          read_loop r, timeout, read_timeout, select_timeout, &block

          ::Process.kill 'KILL', pid
          _, status = ::Process.wait2(pid) # protect from zombies

          compute_exit_code cmd, status, timeout, read_timeout
        end

        private

          def compute_exit_code(command, status, timeout, read_timeout)
            case
            when read_timeout.happened?
              raise Spawn::ReadTimeoutError.new command, read_timeout.value
            when timeout.happened?
              raise Spawn::TimeoutError.new command, timeout.value
            else
              termsig   = status.termsig
              exit_code = status.exitstatus
              exit_code || (termsig && termsig * -1) || -1
            end
          end

          def read_loop(reader, timeout, read_timeout, interval, &block)
            read_timeout.reset

            loop do
              break if timeout.happened?

              rs, _, _ = IO.select([reader], nil, nil, interval)

              if rs
                break if rs[0].eof?
                yield rs[0].readpartial(8192) if block_given?
                read_timeout.reset
              else
                break if read_timeout.happened?
              end
            end
          end

      end
    end
  end
end
