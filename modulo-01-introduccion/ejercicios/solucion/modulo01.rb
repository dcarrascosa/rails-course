# Solución Módulo 01

# Ejercicio 1
class Product
  attr_accessor :name, :price, :stock

  def initialize(name, price, stock)
    @name = name
    @price = price
    @stock = stock
  end

  def available?
    @stock > 0
  end

  def discounted_price(percent)
    @price * (1 - percent / 100.0)
  end
end

p = Product.new("Teclado", 89.99, 5)
puts p.available?            # => true
puts p.discounted_price(10)  # => 80.991

# Ejercicio 2
products = [
  { name: "Teclado", price: 89.99, stock: 5 },
  { name: "Ratón",   price: 29.99, stock: 0 },
  { name: "Monitor", price: 349.0, stock: 2 }
]

available_names = products.select { |p| p[:stock] > 0 }.map { |p| p[:name] }
puts available_names.inspect  # => ["Teclado", "Monitor"]

total_value = products.reduce(0) { |sum, p| sum + p[:price] * p[:stock] }
puts total_value  # => 1147.95

# Ejercicio 3
module Auditable
  def created_info
    "Creado: #{Time.now}"
  end

  def updated_info
    "Actualizado: #{Time.now}"
  end
end

class Task
  include Auditable
  attr_accessor :title

  def initialize(title)
    @title = title
  end
end

t = Task.new("Revisar PR")
puts t.created_info
