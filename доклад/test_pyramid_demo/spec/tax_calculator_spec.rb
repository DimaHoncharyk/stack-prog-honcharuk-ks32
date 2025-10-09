require "spec_helper"
require "tax_calculator"
RSpec.describe TaxCalculator do
  it "рахує податок" do
    calc = TaxCalculator.new(rate: 0.2)
    expect(calc.tax_for(1000)).to eq(200)
  end
end
