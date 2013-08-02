require 'spec_helper'
require 'timeout'

describe Evrone::Common::Spawn::Process do
  let(:collected) { "" }

  subject { collected }

  it "run command successfuly" do
    code = run "echo $HOME"
    expect(subject).to eq "#{ENV['HOME']}\n"
    expect(code).to eq 0
  end

  it "run command with env successfuly" do
    code = run( {'FOO' => "BAR" }, "echo $FOO")
    expect(subject).to eq "BAR\n"
    expect(code).to eq 0
  end

  it 'run command with env and timeout' do
    expect {
      run( {'FOO' => "BAR" }, "echo $FOO && sleep 2", timeout: 1)
    }.to raise_error(described_class.const_get :TimeoutError)
    expect(subject).to eq "BAR\n"
  end

  it 'run and kill process' do
    code = run( "echo $HOME; kill -KILL $$")
    expect(subject).to eq "#{ENV['HOME']}\n"
    expect(code).to eq(-9)
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
