# ================================
# ІНТЕРФЕЙС КОМПОНЕНТА
# ================================
class Implementation
  def operation_implementation
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end

# ================================
# КОНКРЕТНИЙ КОМПОНЕНТ
# ================================
class ConcreteImplementationA < Implementation
  def operation_implementation
    'ConcreteImplementationA: Here\'s the result on the platform A.'
  end
end

class ConcreteImplementationB < Implementation
  def operation_implementation
    'ConcreteImplementationB: Here\'s the result on the platform B.'
  end
end

# ================================
# БАЗОВИЙ МІСТ
# ================================
class Abstraction
  def initialize(implementation)
    @implementation = implementation
  end

  def operation
    "Abstraction: Base operation with:\n"\
      "#{@implementation.operation_implementation}"
  end
end

# ================================
# КОНКРЕТНІ МОСТИ
# ================================
class ExtendedAbstraction < Abstraction
  def operation
    "ExtendedAbstraction: Extended operation with:\n"\
      "#{@implementation.operation_implementation}"
  end
end

# ================================
# КОД КЛІЄНТА
# ================================
def client_code(abstraction)
  print abstraction.operation
end

# ================================
# ПРИКЛАД ВИКОРИСТАННЯ
# ================================
implementation = ConcreteImplementationA.new
abstraction = Abstraction.new(implementation)
client_code(abstraction)

puts "\n\n"

implementation = ConcreteImplementationB.new
abstraction = ExtendedAbstraction.new(implementation)
client_code(abstraction)
