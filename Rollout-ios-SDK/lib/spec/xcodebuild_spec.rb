require 'spec_helper'

describe Xcodebuild do
  describe "#new" do
    it "returns a new Xcodebuild object" do
      @sut = Xcodebuild.new "some string" 
      expect(@sut).to be_an_instance_of Xcodebuild
    end
  end
  it "#returns empty list of rules when file is empty" do
    @sut = Xcodebuild.new "" 
    expect(@sut.rules).to be_empty
  end
  describe "#rules" do
    it "returns one Rule for file with one rule" do
      @sut = Xcodebuild.new ONE_RULE
      expect(@sut.rules.count).to eql 1
    end
    it "returns 2 Rules for file with 2 rules" do
      @sut = Xcodebuild.new TWO_RULES
      expect(@sut.rules.count).to eql 2
    end
    it "returns The Exact rule for one rule" do
      @sut = Xcodebuild.new ONE_RULE
      expect(@sut.rules[0].to_s).to eql ONE_RULE
    end
  end
  it "return the Right rule for ViewController.mm" do
    @sut = Xcodebuild.new TWO_RULES
    expect(@sut.rules[0].source_file).to eql "ViewController.mm"
  end
  it "return the Right arch for ViewController.mm rule" do
    @sut = Xcodebuild.new TWO_RULES
    expect(@sut.rules[0].arch).to eql "armv7"
  end
  it "return the the right language for ViewController.mm rule" do
    @sut = Xcodebuild.new TWO_RULES
    expect(@sut.rules[0].language).to eql "objective-c++"
  end
  describe "#find_rule" do
    it "provides the proper rule for ViewController.mm" do
      @sut = Xcodebuild.new TWO_RULES
      expect(@sut.find_rule("AppDelegate.m", "armv7")).to be(@sut.rules[1])
    end
    it "provides the proper rule for arch" do
      @sut = Xcodebuild.new SAME_RULE_DIFFERENT_ARCH
      expect(@sut.find_rule("ViewController.mm", "i386").arch).to eq("i386")
    end
  end
end
