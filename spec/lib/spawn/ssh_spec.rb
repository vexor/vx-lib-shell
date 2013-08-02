require 'spec_helper'
require 'timeout'

describe Evrone::Common::Spawn::SSH do

  let(:user) { ENV['SSH_USER'] }
  let(:host) { ENV['SSH_HOST'] }
  let(:pass) { ENV['SSH_PASS'] }
  let(:collected) { '' }

  it "run command successfuly" do
    code = run_ssh 'echo $USER'
    expect(collected).to eq "#{user}\n"
    expect(code).to eq 0
  end

  it "run command with error" do
    code = run_ssh 'false'
    expect(collected).to eq ""
    expect(code).to eq 1
  end

  it "run command with env successfuly" do
    code = run_ssh({'FOO' => "BAR"}, 'echo $FOO')
    expect(collected).to match(re "FAILED: couldn't execute command (ssh.channel.env)")
    expect(code).to eq 0
  end

  it 'run command with timeout' do
    expect{
      run_ssh('echo $USER; sleep 2', timeout: 1)
    }.to raise_error(described_class.const_get :TimeoutError)
  end

  it 'run command with timeout successfuly' do
    code = run_ssh('echo $USER; sleep 1', timeout: 2)
    expect(collected).to eq "#{user}\n"
    expect(code).to eq 0
  end

  it 'run and kill process' do
    code = run_ssh("echo $USER; kill -9 $$")
    expect(collected).to eq "#{user}\n"
    expect(code).to eq(-1)
  end

  it 'run and interupt process' do
    code = run_ssh("echo $USER; kill -9 $$")
    expect(collected).to eq "#{user}\n"
    expect(code).to eq(-1)
  end

  def open_ssh(&block)
    described_class.open(host, user, password: pass, verbose: 1, &block)
  end

  def re(s)
    Regexp.escape s
  end

  def run_ssh(*args)
    timeout do
      open_ssh do |ssh|
        ssh.spawn(*args) do |s|
          collected << s
        end
      end
    end
  end

  def timeout
    Timeout.timeout(10) do
      yield
    end
  end
end
