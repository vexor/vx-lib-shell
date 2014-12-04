require 'spec_helper'
require 'timeout'
require 'net/ssh'

describe Vx::Lib::Shell::SSH, ssh: true do

  let(:user) { ENV['SSH_USER'] || 'vagrant' }
  let(:host) { ENV['SSH_HOST'] || 'localhost' }
  let(:pass) { ENV['SSH_PASS'] || 'vagrant' }
  let(:port) { ENV['SSH_PORT'] || 2222 }
  let(:collected) { '' }

  def conn
    @conn ||=
      Net::SSH.start(
        host, user, {
          password: pass,
          port:     port,
          verbose:  2
        }
      )
  end

  it "run command successfuly" do
    code = run_ssh 'echo $HOME'
    expect(collected).to match(/\/home\//)
    expect(code).to eq 0
  end

  it "run command with error" do
    code = run_ssh 'false'
    expect(collected).to eq ""
    expect(code).to eq 1
  end

  context "timeout" do
    it 'run command with timeout' do
      expect{
        run_ssh('echo $USER; sleep 0.5', timeout: 0.2)
      }.to raise_error(Vx::Lib::Shell::TimeoutError)
    end

    it 'run command with timeout successfuly' do
      code = run_ssh('echo $USER; sleep 0.2', timeout: 1)
      expect(collected).to eq "#{user}\r\n"
      expect(code).to eq 0
    end
  end

  context "read_timeout" do
    it 'run command with read timeout' do
      expect{
        run_ssh('sleep 0.5', read_timeout: 0.2)
      }.to raise_error(Vx::Lib::Shell::ReadTimeoutError)
      expect(collected).to eq ""
    end

    it 'run command with read timeout in loop' do
      expect{
        run_ssh('sleep 0.1 ; echo $USER ; sleep 0.5', read_timeout: 0.3)
      }.to raise_error(Vx::Lib::Shell::ReadTimeoutError)
      expect(collected).to eq "#{user}\r\n"
    end

    it 'run command with read timeout successfuly' do
      code = run_ssh('echo $USER; sleep 0.1', read_timeout: 0.5)
      expect(collected).to eq "#{user}\r\n"
      expect(code).to eq 0
    end

    it 'run command with read timeout in loop successfuly' do
      code = run_ssh('sleep 0.3 ; echo $USER; sleep 0.3 ; echo $USER', read_timeout: 0.5)
      expect(collected).to eq "#{user}\r\n#{user}\r\n"
      expect(code).to eq 0
    end
  end

  it 'run and kill process' do
    code = run_ssh("echo $USER; kill -9 $$")
    expect(collected).to eq "#{user}\r\n"
    expect(code).to eq(-4)
  end

  it 'run and interupt process' do
    code = run_ssh("echo $USER; kill -9 $$")
    expect(collected).to eq "#{user}\r\n"
    expect(code).to eq(-4)
  end

  it "should copy stdin" do
    io = StringIO.new("echo foo ; exit\n")
    code = run_ssh(stdin: io)
    expect(collected).to match "foo\r\n"
    expect(code).to eq 0
  end

  def open_ssh(&block)
    described_class.open(host, user, password: pass, paranoid: false, verbose: 2, port: port, &block)
  end

  def re(s)
    Regexp.escape s
  end

  def run_ssh(*args)
    @proxy ||= ShellTest.new
    timeout do
      @proxy.sh(:ssh, conn).exec(*args) do |out|
        collected << out
      end
    end
  end

  def timeout
    Timeout.timeout(3) do
      yield
    end
  end
end
