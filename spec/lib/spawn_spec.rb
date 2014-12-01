require 'spec_helper'

describe Vx::Lib::Spawn do

  subject { Object.new }

  before { subject.extend described_class }

  context "spawn" do
    it "should be" do
      expect(subject.spawn 'true').to eq 0
    end
  end

  context "open_ssh" do
    let(:user) { ENV['SSH_USER'] || 'vagrant' }
    let(:host) { ENV['SSH_HOST'] || 'localhost' }
    let(:pass) { ENV['SSH_PASS'] || 'vagrant' }
    let(:port) { ENV['SSH_PORT'] || 2222 }
    let(:ssh)  { nil }

    it "should be" do
      subject.open_ssh(host, user, password: pass, port: port) do |ssh|
        expect(ssh.spawn 'true').to eq 0
      end
    end
  end
end

