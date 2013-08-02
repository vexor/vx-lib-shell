require 'net/ssh'
require 'timeout'

module Evrone
  module Common
    module Spawn
      module SSH

        class << self
          def open(host, user, options = {}, &block)
            user ||= ENV['SSH_USER']
            host ||= ENV['SSH_HOST']

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
            channel.active?

            if time_end && Time.now > time_end
              timeout_error = true
              false
            end
          end

          timeout_error ?
            raise(TimeoutError, "#{cmd} execution expired") :
            exit_code
        end

        class TimeoutError < ::Timeout::Error ; end
        class ReadTimeoutError < TimeoutError ; end

        private

          def spawn_channel(env, command, &block)
            @ssh.open_channel do |channel|

              env.each do |k, v|
                channel.env k, v
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
