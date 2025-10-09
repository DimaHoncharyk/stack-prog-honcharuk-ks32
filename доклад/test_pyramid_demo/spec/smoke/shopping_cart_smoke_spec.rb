require "spec_helper"
require "shopping_cart"

RSpec.describe "Smoke test: ShoppingCart basic run" do
  it "не падає на базовому сценарії" do
    tax   = TaxCalculator.new(rate: 0.2)
    promo = PromoEngine.new
    cart  = ShoppingCart.new(tax_calculator: tax, promo_engine: promo)

    cart.add("Notebook", 2000)
    cart.add("Pencil", 500, 2)

    total = cart.total_cents(promo_code: :WELCOME10)
    puts "\nSmoke total: #{total} копійок"

    # Smoke-тест лише перевіряє, що результат взагалі є і > 0
    expect(total).to be > 0
  end
end
