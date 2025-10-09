class TaxCalculator
  def initialize(rate:)
    @rate = rate
  end

  def tax_for(amount_cents)
    raise ArgumentError, "Amount must be positive" if amount_cents < 0
    (amount_cents * @rate).round
  end
end
