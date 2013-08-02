require 'spec_helper'
require 'timeout'

describe Evrone::Common::Spawn::Process do
  let(:collected) { "" }
  let(:user)      { ENV['USER'] }

  subject { collected }

  it "run command successfuly" do
    code = run "echo $USER"
    expect(subject).to eq "#{user}\n"
    expect(code).to eq 0
  end

  it "run command with error" do
    code = run( "false")
    expect(subject).to eq ""
    expect(code).to eq 1
  end


  it "run command with env successfuly" do
    code = run( {'FOO' => "BAR" }, "echo $FOO")
    expect(subject).to eq "BAR\n"
    expect(code).to eq 0
  end

  it 'run command with timeout' do
    expect {
      run("echo $USER && sleep 2", timeout: 1)
    }.to raise_error(described_class.const_get :TimeoutError)
    expect(subject).to eq "#{user}\n"
  end

  it 'run command with timeout successfuly' do
    code = run( {'FOO' => "BAR" }, "echo $FOO && sleep 1", timeout: 2)
    expect(subject).to eq "BAR\n"
    expect(code).to eq 0
  end

  it 'run and kill process' do
    code = run( "echo $USER; kill -KILL $$")
    expect(subject).to eq "#{user}\n"
    expect(code).to eq(-9)
  end

  it 'run and interupt process' do
    code = run( "echo $USER; kill -INT $$")
    expect(subject).to eq "#{user}\n"
    expect(code).to eq(-2)
  end

  def run(*args, &block)
    timeout do
      described_class.spawn(*args) do |out|
        collected << out
      end
    end
  end

  def timeout
    Timeout.timeout(10) do
      yield
    end
  end
end
