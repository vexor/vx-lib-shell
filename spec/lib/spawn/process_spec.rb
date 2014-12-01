require 'spec_helper'
require 'timeout'

describe Vx::Lib::Spawn::Process do
  let(:collected) { "" }
  let(:user)      { ENV['USER'] }

  subject { collected }

  [true, false].each do |pty|
    context "with pty: #{pty.inspect}" do

      it "run command successfuly" do
        code = run "echo $USER", pty: pty
        expect(subject.strip).to eq "#{user}"
        expect(code).to eq 0
      end

      it "run command with error" do
        code = run "false", pty: pty
        expect(subject).to eq ""
        expect(code).to eq 1
      end

      context "timeout" do
        it 'run command with timeout' do
          expect {
            run("echo $USER && sleep 0.5", timeout: 0.2, pty: pty)
          }.to raise_error(Vx::Lib::Spawn::TimeoutError)
          expect(subject.strip).to eq "#{user}"
        end

        it 'run command with timeout successfuly' do
          code = run("echo BAR && sleep 0.1", timeout: 0.5, pty: pty)
          expect(subject.strip).to eq "BAR"
          expect(code).to eq 0
        end
      end

      context "read_timeout" do
        it 'run command with read timeout' do
          expect{
            run('sleep 0.5', read_timeout: 0.2, pty: pty)
          }.to raise_error(Vx::Lib::Spawn::ReadTimeoutError)
          expect(collected).to eq ""
        end

        it 'run command with read timeout in loop' do
          expect{
            run('sleep 0.1 ; echo $USER ; sleep 0.5', read_timeout: 0.3, pty: pty)
          }.to raise_error(Vx::Lib::Spawn::ReadTimeoutError)
          expect(collected.strip).to eq "#{user}"
        end

        it 'run command with read timeout successfuly' do
          code = run('echo $USER; sleep 0.1', read_timeout: 0.5, pty: pty)
          expect(collected.strip).to eq "#{user}"
          expect(code).to eq 0
        end

        it 'run command with read timeout in loop successfuly' do
          code = run('sleep 0.3 ; echo $USER; sleep 0.3 ; echo $USER', read_timeout: 0.5, pty: pty)
          expect(collected).to eq "#{user}\n#{user}\n"
          expect(code).to eq 0
        end
      end

      it 'run and kill process' do
        code = run( "echo $USER; kill -KILL $$", pty: pty)
        expect(subject).to eq "#{user}\n"
        expect(code).to eq(-9)
      end

      it 'run and interupt process' do
        code = run( "echo $USER; kill -INT $$", pty: pty)
        expect(subject).to eq "#{user}\n"
        expect(code).to eq(-2)
      end

      it "should copy stdin" do
        io = StringIO.new("echo foo")
        code = run("/bin/sh", stdin: io, pty: pty)
        expect(subject).to eq "foo\n"
        expect(code).to eq 0
      end
    end
  end

  def run(*args, &block)
    timeout do
      described_class.spawn(*args) do |out|
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
