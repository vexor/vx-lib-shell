require 'spec_helper'
require 'timeout'

describe Vx::Common::Spawn::SSH, ssh: true do

  let(:user) { ENV['SSH_USER'] || 'vagrant' }
  let(:host) { ENV['SSH_HOST'] || 'localhost' }
  let(:pass) { ENV['SSH_PASS'] || 'vagrant' }
  let(:port) { ENV['SSH_PORT'] || 2222 }
  let(:collected) { '' }

  it "run command successfuly" do
    code = run_ssh 'echo $USER'
    expect(collected).to eq "#{user}\n"
    expect(code).to eq 0
  end

  it "run command successfuly with pty" do
    code = run_ssh 'env', pty: true
    expect(collected).to match(/SSH_TTY=/)
    expect(code).to eq 0
  end

  it "run command with error" do
    code = run_ssh 'false'
    expect(collected).to eq ""
    expect(code).to eq 1
  end

  it "run command with env successfuly" do
    code = run_ssh({'FOO' => "BAR"}, "sh -c 'echo $FOO'")
    expect(collected).to eq "BAR\n"
    expect(code).to eq 0
  end

  it "run command with chdir successfuly" do
    code = run_ssh("echo $(pwd)", chdir: "/tmp")
    expect(collected).to eq "/tmp\n"
    expect(code).to eq 0
  end

  it "run command with chdir and env successfuly" do
    code = run_ssh(
      {'FOO' => "BAR"},
      "sh -c 'echo $FOO' ; echo $(pwd)",
      chdir: '/tmp'
    )
    expect(collected).to eq "BAR\n/tmp\n"
    expect(code).to eq 0
  end

  context "timeout" do
    it 'run command with timeout' do
      expect{
        run_ssh('echo $USER; sleep 0.5', timeout: 0.2)
      }.to raise_error(Vx::Common::Spawn::TimeoutError)
    end

    it 'run command with timeout successfuly' do
      code = run_ssh('echo $USER; sleep 0.2', timeout: 1)
      expect(collected).to eq "#{user}\n"
      expect(code).to eq 0
    end
  end

  context "read_timeout" do
    it 'run command with read timeout' do
      expect{
        run_ssh('sleep 0.5', read_timeout: 0.2)
      }.to raise_error(Vx::Common::Spawn::ReadTimeoutError)
      expect(collected).to eq ""
    end

    it 'run command with read timeout in loop' do
      expect{
        run_ssh('sleep 0.1 ; echo $USER ; sleep 0.5', read_timeout: 0.3)
      }.to raise_error(Vx::Common::Spawn::ReadTimeoutError)
      expect(collected).to eq "#{user}\n"
    end

    it 'run command with read timeout successfuly' do
      code = run_ssh('echo $USER; sleep 0.1', read_timeout: 0.5)
      expect(collected).to eq "#{user}\n"
      expect(code).to eq 0
    end

    it 'run command with read timeout in loop successfuly' do
      code = run_ssh('sleep 0.3 ; echo $USER; sleep 0.3 ; echo $USER', read_timeout: 0.5)
      expect(collected).to eq "#{user}\n#{user}\n"
      expect(code).to eq 0
    end
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
    described_class.open(host, user, password: pass, paranoid: false, verbose: 2, port: port, &block)
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
