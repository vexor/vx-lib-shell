require File.expand_path('../../lib/vx/lib/shell', __FILE__)

class ShellTest
  include Vx::Lib::Shell
end

RSpec.configure do |c|
  unless ENV['USE_DOCKER']
    c.filter_run_excluding docker: true
  end
end

