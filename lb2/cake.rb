def cut_cake(lines)
  h = lines.size
  w = lines.first.size
  o_lat = 'o'
  o_cyr = 'о'
  is_raisin = ->(ch) { ch == o_lat || ch == o_cyr }

  raisins = []
  h.times { |r| w.times { |c| raisins << [r, c] if is_raisin.call(lines[r][c]) } }
  n = raisins.size
  return [] if n < 2 || n >= 10
  total = h * w
  return [] unless total % n == 0
  area = total / n

  grid = lines.map(&:chars)
  used = Array.new(h) { Array.new(w, false) }

  rects = []
  1.upto(w) { |rw| rh = area / rw; rects << [rw, rh] if area % rw == 0 && rh <= h }
  rects.sort_by! { |rw, rh| [-rw, -rh] }

  pieces = []
  count = ->(r0, c0, rw, rh) do
    cnt = 0
    r0.upto(r0 + rh - 1) { |r| c0.upto(c0 + rw - 1) { |c| cnt += 1 if is_raisin.call(grid[r][c]) } }
    cnt
  end

  next_free = -> do
    h.times { |r| w.times { |c| return [r, c] unless used[r][c] } }
    nil
  end

  extract = ->(r0, c0, rw, rh) { (r0...(r0 + rh)).map { |r| grid[r][c0, rw].join } }
  mark = ->(r0, c0, rw, rh, val) { r0.upto(r0+rh-1) { |r| c0.upto(c0+rw-1) { |c| used[r][c] = val } } }

  solved = false
  dfs = lambda do
    cell = next_free.call
    if cell.nil?
      solved = true
      return true
    end
    r0, c0 = cell
    rects.each do |rw, rh|
      next if c0 + rw > w || r0 + rh > h
      overlap = false
      r0.upto(r0+rh-1) { |r| c0.upto(c0+rw-1) { |c| overlap = true if used[r][c] } }
      next if overlap
      next unless count.call(r0, c0, rw, rh) == 1
      mark.call(r0, c0, rw, rh, true)
      pieces << extract.call(r0, c0, rw, rh)
      return true if dfs.call
      pieces.pop
      mark.call(r0, c0, rw, rh, false)
    end
    false
  end
  dfs.call
  solved ? pieces : []
end
if __FILE__ == $PROGRAM_NAME
# Приклад 1
cake1 = [
  "........",
  "..o.....",
  "...o....",
  "........"
]
p cut_cake(cake1)

# Приклад з умови (гор/верт/міксподіл)
cake2 = [
  ".о......",
  "......о.",
  "....о...",
  "..о....."
]
p cut_cake(cake2)

# Приклад “різні форми, але однакова площа”
cake3 = [
  ".о.о....",
  "........",
  "....о...",
  "........",
  ".....о..",
  "........"
]
p cut_cake(cake3)
end

