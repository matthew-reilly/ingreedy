# encoding: utf-8
require "spec_helper"

describe Ingreedy, ".parse" do
  it "parses a simple example correctly" do
    result = Ingreedy.parse("1 lb potatoes")

    expect(result.amount).to eq(1)
    expect(result.unit).to eq(:pound)
    expect(result.ingredient).to eq("potatoes")
  end
end
