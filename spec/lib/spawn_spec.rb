require 'spec_helper'

describe Evrone::Common::Spawn do

  subject { Object.new }

  before { subject.extend described_class }

  context "spawn" do
    it "should be" do
      expect(subject.spawn 'true').to eq 0
    end
  end

  context "open_ssh" do
    let(:ssh) { nil }
    it "should be" do
      subject.open_ssh(ENV['SSH_HOST'], ENV['SSH_USER'], password: ENV['SSH_PASS']) do |ssh|
        expect(ssh.spawn 'true').to eq 0
      end
    end
  end
end

