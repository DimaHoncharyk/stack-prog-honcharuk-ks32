require_relative "tax_calculator"
require_relative "promo_engine"

class ShoppingCart
  Item = Struct.new(:title, :price_cents, :qty, keyword_init: true)

  def initialize(tax_calculator:, promo_engine:)
    @tax_calculator = tax_calculator
    @promo_engine   = promo_engine
    @items = []
  end

  def add(title, price_cents, qty = 1)
    @items << Item.new(title: title, price_cents: price_cents, qty: qty)
  end

  def subtotal_cents
    @items.sum { |i| i.price_cents * i.qty }
  end

  def total_cents(promo_code: nil)
    subtotal = subtotal_cents
    discount = @promo_engine.discount_for(subtotal, code: promo_code)
    subtotal - discount  # без податку
  end
end
