require 'spec_helper'

describe Vx::Lib::Shell::ReadTimeout do
  subject { described_class.new 0.2 }

  it "just created" do
    expect(subject.value).to eq 0.2
    expect(subject).to_not be_happened
  end

  it "should be work" do
    subject.reset
    sleep 0.1
    expect(subject).to_not be_happened

    subject.reset
    sleep 0.3
    expect(subject).to be_happened
  end

  it "do nothing unless value" do
    expect(subject).to_not be_happened
  end

  it "do nothing unless timeout" do
    subject.reset
    sleep 0.1
    expect(subject).to_not be_happened
  end
end
