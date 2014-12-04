require 'net/ssh'
require 'timeout'
require 'shellwords'

module Vx
  module Lib
    module Shell
      class SSH

        attr_reader :host, :user, :options, :connection

        def initialize(ssh)
          @connection = ssh
        end

        def exec(*args, &block)
          options       = args.last.is_a?(Hash) ? args.pop : {}
          command       = args.first
          home          = options[:home] || "$HOME"

          exit_code     = nil
          timeout       = Shell::Timeout.new options.delete(:timeout)
          read_timeout  = Shell::ReadTimeout.new options.delete(:read_timeout)

          prefix = "/usr/bin/env - TERM=ansi USER=$USER HOME=#{home} SHELL=/bin/bash /bin/bash -l"
          command = "#{prefix} -c #{Shellwords.escape command}"

          channel = spawn_channel command, read_timeout, options, &block

          channel.on_request("exit-status") do |_,data|
            exit_code = data.read_long
          end

          channel.on_request("exit-signal") do |_,data|
            exit_code = data.read_long * -1
          end

          pool channel, timeout, read_timeout

          compute_exit_code command, exit_code, timeout, read_timeout
        end

        private

          def request_pty(channel, options)
            channel.request_pty do |_, pty_status|
              raise StandardError, "could not obtain pty (ssh.channel.request_pty)" unless pty_status
              yield if block_given?
            end
          end

          def pool(channel, timeout, read_timeout)
            @connection.loop Shell.pool_interval do
              if read_timeout.happened? || timeout.happened?
                false
              else
                channel.active?
              end
            end
          end

          def compute_exit_code(command, exit_code, timeout, read_timeout)
            case
            when read_timeout.happened?
              raise Shell::ReadTimeoutError.new command, read_timeout.value
            when timeout.happened?
              raise Shell::TimeoutError.new command, timeout.value
            else
              exit_code || -1 # nil exit_code means that the process is killed
            end
          end

          def spawn_channel(command, read_timeout, options, &block)
            @connection.open_channel do |channel|

              request_pty channel, options do

                read_timeout.reset

                channel.exec command do |_, success|

                  unless success
                    raise StandardError, "FAILED: couldn't execute command (ssh.channel.exec)"
                  end

                  channel.on_data do |_, data|
                    yield data if block_given?
                    read_timeout.reset
                  end

                  channel.on_extended_data do |_, _, data|
                    yield data if block_given?
                    read_timeout.reset
                  end

                end
              end
            end

          end

      end
    end
  end
end
