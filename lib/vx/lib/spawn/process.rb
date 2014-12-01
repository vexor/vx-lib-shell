require 'timeout'
require 'pty'
require 'io/console'

module Vx
  module Lib
    module Spawn
      module Process

        extend self

        def spawn(command, options = {}, &block)
          select_timeout = options.delete(:pool_interval) || Spawn.pool_interval
          timeout        = Spawn::Timeout.new options.delete(:timeout)
          read_timeout   = Spawn::ReadTimeout.new options.delete(:read_timeout)

          status = spawn_command_internal(command, options) do |r|
            read_loop r, timeout, read_timeout, select_timeout, &block
          end

          compute_exit_code command, status, timeout, read_timeout
        end

        private

          def request_pipes(options)
            if options[:pty]
              m,s   = PTY.open
              r1,w1 = IO.pipe

              s.raw! # disable newline conversion.
              m.sync = true
              s.sync = true

              [m, s, r1, w1]
            else
              r1,w1 = IO.pipe
              r2,w2 = IO.pipe

              w1.sync = true
              r1.sync = true

              [r1, w1, r2, w2]
            end
          end

          def spawn_command_internal(command, options)
            r1, w1, r2, w2 = request_pipes(options)

            pid = ::Process.spawn(command, in: r2, out: w1, err: w1)

            begin
              if i = options[:stdin]
                IO.copy_stream i, w2
              end
              w2.close
              w1.close

              yield r1
            rescue Errno::EIO
            end

            ::Process.kill 'KILL', pid
            _, status = ::Process.wait2(pid)

            r1.close
            r2.close

            status
          end

          def compute_exit_code(command, status, timeout, read_timeout)
            case
            when read_timeout.happened?
              raise Spawn::ReadTimeoutError.new command, read_timeout.value
            when timeout.happened?
              raise Spawn::TimeoutError.new command, timeout.value
            else
              termsig   = status && status.termsig
              exit_code = status && status.exitstatus
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
