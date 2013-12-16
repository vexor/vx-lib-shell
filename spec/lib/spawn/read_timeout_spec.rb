require 'spec_helper'

describe Vx::Common::Spawn::ReadTimeout do
  subject { described_class.new 0.2 }

  context "just created" do
    its(:value)     { should eq 0.2 }
    its(:happened?) { should be_false }
  end

  it "should be work" do
    subject.reset
    sleep 0.1
    expect(subject.happened?).to be_false

    subject.reset
    sleep 0.3
    expect(subject.happened?).to be_true
  end

  it "do nothing unless value" do
    expect(subject.happened?).to be_false
  end

  it "do nothing unless timeout" do
    subject.reset
    sleep 0.1
    expect(subject.happened?).to be_false
  end
end
