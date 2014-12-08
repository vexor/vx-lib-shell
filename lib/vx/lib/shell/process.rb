require 'timeout'
require 'pty'
require 'shellwords'
require 'io/console'

module Vx
  module Lib
    module Shell
      class Process

        def exec(*args, &block)
          options        = args.last.is_a?(Hash) ? args.pop.dup : {}
          command        = args.first
          home           = options[:home] || "$HOME"

          select_timeout = options.delete(:pool_interval) || Shell.pool_interval
          timeout        = Shell::Timeout.new options.delete(:timeout)
          read_timeout   = Shell::ReadTimeout.new options.delete(:read_timeout)

          prefix = "/usr/bin/env - TERM=ansi USER=$USER HOME=#{home} SHELL=/bin/bash /bin/bash -l"
          command = "#{prefix} -c #{Shellwords.escape command}"

          status = spawn_command_internal(command, options) do |r|
            read_loop r, timeout, read_timeout, select_timeout, &block
          end

          compute_exit_code command, status, timeout, read_timeout
        end

        private

          def request_pipes(options)
            m,s   = PTY.open

            s.raw! # disable newline conversion.
            m.sync = true
            s.sync = true

            [m, s]
          end

          def spawn_command_internal(command, options)
            r1, w1 = request_pipes(options)

            pid = ::Process.spawn(command, out: w1, err: w1)

            begin
              w1.close

              yield r1
            rescue Errno::EIO
            end

            ::Process.kill 'KILL', pid
            _, status = ::Process.wait2(pid)

            r1.close

            status
          end

          def compute_exit_code(command, status, timeout, read_timeout)
            case
            when read_timeout.happened?
              raise Shell::ReadTimeoutError.new command, read_timeout.value
            when timeout.happened?
              raise Shell::TimeoutError.new command, timeout.value
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
                re = rs[0].readpartial(8192)
                if block_given?
                  yield re
                end
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
