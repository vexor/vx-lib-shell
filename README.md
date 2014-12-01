# Vx::Lib::Spawn

This gem helps to spawn processes in a shell capturing output in realtime.
It also allows to set the temeouts.

## Requirements

MRI 1.9.3, 2.0.0, 2.1.x.

## Installation

Add this line to your application's Gemfile:

    gem 'vx-lib-spawn'

And then execute the bundler:

    $ bundle

Or install it via `gem` command:

    $ gem install vx-lib-spawn

## Quick Start

The following snippet demonstrates the usage:

```ruby
include Vx::Lib::Spawn

spawn "ls -la" do |output|
  print output
  # prints directory listing
end

spawn("echo value", timeout: 10) do |output|
  print output
  #  its print "value\n"
end
```

```ruby
# Spawn remote processes example

open_ssh('localhost', 'user') do |ssh|
  ssh.spawn("ls -la") do |output|
    print output
    # prints directory listing
  end

  spawn("echo value", read_timeout: 10) do |output|
    print output
    #  its print "value\n"
  end
end

```

### Timeouts

When a timeout is reached spawn raises ```Vx::Lib::Spawn::TimeoutError``` or
```Vx::Lib::Spawn::ReadTimeoutError```. Both exceptions inherit
from Timeout::Error

### Return values

Both ```spawn``` methods return process exit code. If a process was terminated by a signal, for example
KILL or INT, the methods return negative number identical to a signal number (-9 for KILL, etc.)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

