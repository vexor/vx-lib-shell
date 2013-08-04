# Evrone::Common::Spawn

This gem helps to spawn system, ssh processes, capturing output in realtime,
allow to set temeouts and read timeouts.

* [![Build Status](https://travis-ci.org/evrone/evrone-common-spawn.png)](https://travis-ci.org/evrone/evrone-common-spawn)
* [![Code Climate](https://codeclimate.com/github/evrone/evrone-common-spawn.png)](https://codeclimate.com/github/evrone/evrone-common-spawn)

## Requirements

MRI 1.9.3 or 2.0.0.

## Installation

Add this line to your application's Gemfile:

    gem 'evrone-common-spawn'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install evrone-common-spawn

## Quick Start

Below is a small snippet that demonstrates how to use

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

When timeout happened, spawn raises ```Evrone::Common::Spawn::TimeoutError``` or
```Evrone::Common::Spawn::ReadTimeoutError```, both exception classes inherited
from Timeout::Error

### Return values

Both ```spawn``` methods return process exit code, if process was killed by signal, for example
KILL or INT, return negative signal number (for KILL was -9)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

