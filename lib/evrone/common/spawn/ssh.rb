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
          timeout_error = false
          time_end      = (timeout.to_i > 0) ? Time.new + timeout : nil
          pool_timeout  = 0.25

          channel = spawn_channel env, command, &block

          channel.on_request("exit-status") do |_,data|
            exit_code = data.read_long
          end

          @ssh.loop pool_timeout do
            if time_end && Time.now > time_end
              timeout_error = true
              false
            else
              channel.active?
            end
          end

          timeout_error ?
            raise(Spawn::TimeoutError, "#{command} execution expired") :
            exit_code || -1 # nil exit_code means that the process is killed
        end

        private

          def spawn_channel(env, command, &block)
            @ssh.open_channel do |channel|

              env.each do |k, v|
                channel.env k, v do |_, success|
                  yield "FAILED: couldn't execute command (ssh.channel.env)\n" if block_given?
                end
              end

              channel.exec command do |_, success|

                unless success
                  yield "FAILED: couldn't execute command (ssh.channel.exec)\n" if block_given?
                end

                channel.on_data do |_,data|
                  yield data if block_given?
                end

                channel.on_extended_data do |_,type,data|
                  yield data if block_given?
                end

              end
            end
          end

      end
    end
  end
end