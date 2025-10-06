# ---------------- UnitConverter ----------------
class UnitConverter
  UNIT_TYPES = {
    g: :mass, kg: :mass,
    ml: :volume, l: :volume,
    pcs: :count
  }.freeze
  BASE_UNIT = { mass: :g, volume: :ml, count: :pcs }.freeze
  TO_BASE = { g: 1.0, kg: 1000.0, ml: 1.0, l: 1000.0, pcs: 1.0 }.freeze
  def self.type_of(unit)
    UNIT_TYPES[unit] or raise ArgumentError, "Невідомий юніт: #{unit}"
  end
  def self.base_of(unit)
    BASE_UNIT[type_of(unit)]
  end
  def self.to_base(qty, unit)
    (qty.to_f * TO_BASE[unit]).tap do |_|
      raise ArgumentError, "Невідомий юніт: #{unit}" unless TO_BASE.key?(unit)
    end
  end
  def self.convert(qty, from_unit, to_unit)
    from_t = type_of(from_unit)
    to_t   = type_of(to_unit)
    raise ArgumentError, "Заборонено конвертувати масу ↔ об'єм" if from_t != to_t
    to_base(qty, from_unit) / TO_BASE[to_unit]
  end
end
# ---------------- Ingredient ----------------
class Ingredient
  attr_reader :name, :base_unit, :calories_per_base_unit
  def initialize(name:, unit:, calories_per_unit:)
    @name = name.to_s.downcase
    @base_unit = UnitConverter.base_of(unit)
    @calories_per_base_unit = calories_per_unit.to_f
  end
end
# ---------------- RecipeItem ----------------
class RecipeItem
  attr_reader :ingredient, :qty, :unit
  def initialize(ingredient:, qty:, unit:)
    @ingredient = ingredient
    @qty = qty.to_f
    @unit = unit
    # Заборона маса↔об'єм
    it = UnitConverter.type_of(ingredient.base_unit)
    ut = UnitConverter.type_of(unit)
    raise ArgumentError, "Заборонено змішувати масу й об'єм для '#{ingredient.name}'" if it != ut
  end
  def qty_in_base
    UnitConverter.to_base(@qty, @unit)
  end
end
# ---------------- Recipe ----------------
class Recipe
  attr_reader :name, :steps, :items
  def initialize(name:, steps:, items:)
    @name = name
    @steps = steps
    @items = items # масив RecipeItem
  end
  def need
    need_hash = Hash.new(0.0)
    @items.each do |it|
      need_hash[it.ingredient.name] += it.qty_in_base
    end
    need_hash
  end
  def calories_total
    @items.sum { |it| it.qty_in_base * it.ingredient.calories_per_base_unit }
  end
end
# ---------------- Pantry ----------------
class Pantry
  def initialize
    @store = Hash.new { |h, k| h[k] = { qty: 0.0, unit: nil } }
  end
  def add(name, qty, unit)
    name = name.to_s.downcase
    base_unit = UnitConverter.base_of(unit)
    qty_base = UnitConverter.to_base(qty, unit)
    if @store[name][:unit] && @store[name][:unit] != base_unit
      raise ArgumentError, "Різні категорії одиниць для '#{name}' у коморі"
    end
    @store[name][:unit] ||= base_unit
    @store[name][:qty] += qty_base
  end
  def available_for(name)
    name = name.to_s.downcase
    @store[name][:qty] || 0.0
  end
  def unit_for(name)
    name = name.to_s.downcase
    @store[name][:unit]
  end
end
# ---------------- Planner ----------------
class Planner
  Result = Struct.new(:per_item, :total_calories, :total_cost, keyword_init: true)
  def self.plan(recipes, pantry, price_list, ingredients_index)
    need = Hash.new(0.0)
    calories_all = 0.0
    recipes.each do |r|
      r.need.each { |name, q| need[name] += q }
      calories_all += r.calories_total
    end
    have = Hash.new(0.0)
    need.keys.each { |name| have[name] = pantry.available_for(name) }
    per_item = {}
    total_cost = 0.0
    need.each do |name, q_need|
      q_have = have[name] || 0.0
      deficit = [q_need - q_have, 0.0].max
      unit = pantry.unit_for(name) || ingredients_index[name]&.base_unit
      per_item[name] = { need: q_need, have: q_have, deficit: deficit, unit: unit || :g }
      price = price_list[name] || 0.0
      total_cost += deficit * price
    end
    Result.new(per_item: per_item, total_calories: calories_all, total_cost: total_cost)
  end
end
# ---------------- Helpers (formatting) ----------------
def fmt_qty(x)
  ((x - x.round).abs < 1e-9) ? x.round.to_s : ('%.2f' % x)
end
def unit_label(u)
  { g: 'г', ml: 'мл', pcs: 'шт' }[u] || u.to_s
end
# ====================== DEMO ======================
if __FILE__ == $0
  ingredients = [
    Ingredient.new(name: "борошно", unit: :g,   calories_per_unit: 3.64),
    Ingredient.new(name: "молоко",  unit: :ml,  calories_per_unit: 0.06),
    Ingredient.new(name: "яйце",    unit: :pcs, calories_per_unit: 72.0),
    Ingredient.new(name: "паста",   unit: :g,   calories_per_unit: 3.5),
    Ingredient.new(name: "соус",    unit: :ml,  calories_per_unit: 0.2),
    Ingredient.new(name: "сир",     unit: :g,   calories_per_unit: 4.0)
  ]
  ING = ingredients.map { |i| [i.name, i] }.to_h
  pantry = Pantry.new
  pantry.add("борошно", 1, :kg)
  pantry.add("молоко", 0.5, :l)
  pantry.add("яйце", 6, :pcs)
  pantry.add("паста", 300, :g)
  pantry.add("сир", 150, :g)

  price_list = {
    "борошно" => 0.02, # за 1 г
    "молоко"  => 0.015,# за 1 мл
    "яйце"    => 6.0,  # за 1 шт
    "паста"   => 0.03, # за 1 г
    "соус"    => 0.025,# за 1 мл
    "сир"     => 0.08  # за 1 г
  }

  omelet = Recipe.new(
    name: "Омлет",
    steps: ["Збити яйця", "Додати молоко і борошно", "Посмажити"],
    items: [
      RecipeItem.new(ingredient: ING["яйце"],   qty: 3,   unit: :pcs),
      RecipeItem.new(ingredient: ING["молоко"], qty: 100, unit: :ml),
      RecipeItem.new(ingredient: ING["борошно"],qty: 20,  unit: :g)
    ]
  )

  pasta = Recipe.new(
    name: "Паста",
    steps: ["Відварити пасту", "Додати соус", "Посипати сиром"],
    items: [
      RecipeItem.new(ingredient: ING["паста"], qty: 200, unit: :g),
      RecipeItem.new(ingredient: ING["соус"],  qty: 150, unit: :ml),
      RecipeItem.new(ingredient: ING["сир"],   qty: 50,  unit: :g)
    ]
  )

  plan = Planner.plan([omelet, pasta], pantry, price_list, ING)

  puts "=== План закупівель та інфо по інгредієнтах (базові од.) ==="
  plan.per_item.each do |name, row|
    u = unit_label(row[:unit])
    line = [
      name.capitalize.ljust(10),
      "потрібно: #{fmt_qty(row[:need])} #{u}",
      "є: #{fmt_qty(row[:have])} #{u}",
      "дефіцит: #{fmt_qty(row[:deficit])} #{u}"
    ].join(" | ")
    puts line
  end
  puts "\n=== Підсумки ==="
  puts "total_calories: #{fmt_qty(plan.total_calories)} ккал"
  puts "total_cost (закупити дефіцит): #{'%.2f' % plan.total_cost} грн"
end
