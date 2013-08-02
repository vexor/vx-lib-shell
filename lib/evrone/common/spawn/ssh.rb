require 'net/ssh'
require 'timeout'

module Evrone
  module Common
    module Spawn
      class SSH

        class << self
          def open(host, user, options = {}, &block)
            ::Net::SSH.start(host, user, {
              forward_agent: true,
              paranoid:      false
            }.merge(options)) do |ssh|
              yield new(ssh)
            end
          end
        end

        attr_reader :host, :user, :options

        def initialize(ssh)
          @ssh = ssh
        end

        def spawn(*args, &block)
          env     = args.first.is_a?(Hash) ? args.shift : {}
          options = args.last.is_a?(Hash)  ? args.pop : {}
          command = args.join(" ")

          exit_code     = nil
          timeout       = options.delete(:timeout)
          read_timeout  = Spawn::ReadTimeout.new options.delete(:read_timeout)
          timeout_error = false
          time_end      = (timeout.to_f > 0) ? Time.new + timeout.to_f : nil

          channel = spawn_channel env, command, read_timeout, &block

          channel.on_request("exit-status") do |_,data|
            exit_code = data.read_long
          end

          @ssh.loop Spawn.pool_interval do
            if read_timeout.happened?
              timeout_error = :read_timeout
              false
            elsif time_end && Time.now > time_end
              timeout_error = :timeout
              false
            else
              channel.active?
            end
          end

          case timeout_error
          when :read_timeout
            raise Spawn::ReadTimeoutError.new command, read_timeout.value
          when :timeout
            raise Spawn::TimeoutError.new command, timeout
          else
            exit_code || -1 # nil exit_code means that the process is killed
          end
        end

        private

          def spawn_channel(env, command, read_timeout, &block)

            @ssh.open_channel do |channel|
              read_timeout.reset

              env.each do |k, v|
                channel.env k, v do |_, success|
                  yield "FAILED: couldn't execute command (ssh.channel.env)\n" if block_given?
                end
              end

              channel.exec command do |_, success|

                unless success
                  yield "FAILED: couldn't execute command (ssh.channel.exec)\n" if block_given?
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
