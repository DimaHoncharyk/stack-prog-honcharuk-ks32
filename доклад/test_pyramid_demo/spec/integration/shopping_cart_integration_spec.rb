require "spec_helper"
require "shopping_cart"

RSpec.describe "Cart integration" do
  it "рахує total" do
    tax = TaxCalculator.new(rate: 0.2)
    promo = PromoEngine.new
    cart = ShoppingCart.new(tax_calculator: tax, promo_engine: promo)

    cart.add("Book", 2500)
    cart.add("Pen", 500)

    expect(cart.total_cents(promo_code: :WELCOME10)).to eq(2700)
  end
end
