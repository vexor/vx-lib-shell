# Evrone::Common::Spawn

This gem helps to spawn processes in a shell capturing output in realtime.
It also allows to set the temeouts.

* [![Build Status](https://travis-ci.org/evrone/evrone-common-spawn.png)](https://travis-ci.org/evrone/evrone-common-spawn)
* [![Code Climate](https://codeclimate.com/github/evrone/evrone-common-spawn.png)](https://codeclimate.com/github/evrone/evrone-common-spawn)

## Requirements

MRI 1.9.3 or 2.0.0.

## Installation

Add this line to your application's Gemfile:

    gem 'evrone-common-spawn'

And then execute the bundler:

    $ bundle

Or install it via `gem` command:

    $ gem install evrone-common-spawn

## Quick Start

The following snippet demonstrates the usage:

```ruby
# Spawn system processes example

include Evrone::Common::Spawn

spawn "ls -la" do |output|
  print output
  # prints directory listing
end

spawn({'ENV_VAR' => 'VALUE'}, "echo $VALUE", timeout: 10) do |output|
  print output
  #  its print "VALUE\n"
end
```


```ruby
# Spawn remote processes example

open_ssh('localhost', 'user') do |ssh|
  ssh.spawn("ls -la") do |output|
    print output
    # prints directory listing
  end

  spawn({'ENV_VAR' => 'VALUE'}, "echo $VALUE", read_timeout: 10) do |output|
    print output
    #  its print "VALUE\n"
  end
end

```

### Timeouts

When a timeout is reached spawn raises ```Evrone::Common::Spawn::TimeoutError``` or
```Evrone::Common::Spawn::ReadTimeoutError```. Both exceptions inherit
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

