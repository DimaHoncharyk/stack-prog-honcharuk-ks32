class Bag
  include Enumerable
  def initialize(items = [])
    @items = items
  end
  def each(&block)
    @items.each(&block)
  end
  def size
    @items.size
  end
  def median
    sorted = @items.sort
    len = sorted.length
    return nil if len == 0
    len.odd? ? sorted[len / 2] : (sorted[len / 2 - 1] + sorted[len / 2]) / 2.0
  end

  def frequencies
    freq = Hash.new(0)
    @items.each { |item| freq[item] += 1 }
    freq
  end
end
bag = Bag.new([3, 1, 2, 3, 2, 3])
puts bag.size
puts bag.median
puts bag.frequencies
puts bag.max
puts bag.sum
puts bag.sum / bag.size.to_f