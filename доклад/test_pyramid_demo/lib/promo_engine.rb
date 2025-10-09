class PromoEngine
  CODES = { WELCOME10: 0.10, VIP20: 0.20 }.freeze

  def discount_for(sum, code: nil)
    return 0 unless code && CODES.key?(code.to_sym)
    (sum * CODES[code.to_sym]).round
  end
end
