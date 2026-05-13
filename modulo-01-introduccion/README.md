# Módulo 01 — Ruby para Desarrolladores C#

## Objetivos

- Leer y escribir Ruby básico partiendo de tu conocimiento de C#
- Entender las diferencias clave de tipado, bloques y símbolos
- Ejecutar Ruby en la terminal sin ningún framework

---

## 1. Tipado dinámico vs estático

En C# el compilador verifica tipos en tiempo de compilación. Ruby resuelve tipos en tiempo de ejecución.

```csharp
// C#
string name = "David";
int age = 40;
bool active = true;
```

```ruby
# Ruby — no declaras tipos
name = "David"
age = 40
active = true
```

> **Clave:** En Ruby, `name` es un objeto `String`. Todo es un objeto, incluso los números.

---

## 2. Métodos vs funciones

```csharp
// C#
public string Greet(string name)
{
    return $"Hola, {name}";
}
```

```ruby
# Ruby — def/end, return implícito
def greet(name)
  "Hola, #{name}"  # última expresión es el valor de retorno
end
```

> **Clave:** El `return` es opcional. La última expresión evaluada es el retorno.

---

## 3. Clases y objetos

```csharp
// C#
public class User
{
    public string Name { get; set; }
    public int Age { get; set; }

    public User(string name, int age)
    {
        Name = name;
        Age = age;
    }

    public string Introduce() => $"Soy {Name}, tengo {Age} años";
}

var user = new User("David", 40);
```

```ruby
# Ruby
class User
  attr_accessor :name, :age  # genera getters y setters automáticamente

  def initialize(name, age)  # equivalente al constructor
    @name = name             # @ = variable de instancia
    @age = age
  end

  def introduce
    "Soy #{@name}, tengo #{@age} años"
  end
end

user = User.new("David", 40)
puts user.introduce
```

---

## 4. Colecciones — Arrays y Hashes

```csharp
// C# — List<T> y Dictionary<K,V>
var names = new List<string> { "Ana", "Carlos", "Eva" };
var config = new Dictionary<string, string>
{
    { "env", "production" },
    { "version", "1.0" }
};
```

```ruby
# Ruby — Array y Hash, sin tipos
names = ["Ana", "Carlos", "Eva"]
config = { env: "production", version: "1.0" }  # símbolos como clave

# Acceso
puts names[0]          # => Ana
puts config[:env]      # => production
```

---

## 5. Bloques — el equivalente a lambdas/delegates

En C# usas `Func<T>`, `Action<T>` o expresiones lambda. Ruby tiene **bloques**.

```csharp
// C# — LINQ con lambda
var doubled = numbers.Select(n => n * 2).ToList();
var evens   = numbers.Where(n => n % 2 == 0).ToList();
```

```ruby
# Ruby — bloques con do..end o llaves {}
numbers = [1, 2, 3, 4, 5]

doubled = numbers.map { |n| n * 2 }      # => [2, 4, 6, 8, 10]
evens   = numbers.select { |n| n.even? } # => [2, 4]
total   = numbers.reduce(0) { |sum, n| sum + n } # => 15
```

---

## 6. Módulos vs Interfaces

En C# usas interfaces para contratos y herencia para reutilización. Ruby usa **módulos** (mixins) para ambos.

```csharp
// C#
public interface IGreetable
{
    string Greet();
}

public class Admin : User, IGreetable
{
    public string Greet() => $"Hola, soy administrador";
}
```

```ruby
# Ruby
module Greetable
  def greet
    "Hola, soy #{self.class.name}"
  end
end

class Admin < User
  include Greetable  # mixin — "hereda" el método greet
end

admin = Admin.new("Laura", 35)
puts admin.greet  # => Hola, soy Admin
```

---

## 7. Símbolos

No tienen equivalente directo en C#. Son como strings inmutables e internos, ideales para claves y nombres de métodos.

```ruby
:name       # símbolo
"name"      # string

:name == :name  # => true, mismo objeto en memoria
"name" == "name" # => true, pero son objetos distintos

# Uso típico: claves de hash, opciones de métodos
user = { name: "David", role: :admin }
```

---

## Ejercicios

### Ejercicio 1 — Clase con lógica de negocio

Crea una clase `Product` con atributos `name`, `price` y `stock`. Añade un método `available?` que devuelva `true` si el stock es mayor que 0, y un método `discounted_price(percent)` que aplique un descuento.

```ruby
# Tu solución aquí
class Product
  # ...
end

p = Product.new("Teclado", 89.99, 5)
puts p.available?               # => true
puts p.discounted_price(10)     # => 80.991
```

### Ejercicio 2 — Transformaciones de colecciones

Dado este array de hashes, usa `map`, `select` y `reduce` para:
1. Obtener solo los nombres de productos con stock > 0
2. Calcular el valor total del inventario (precio × stock)

```ruby
products = [
  { name: "Teclado", price: 89.99, stock: 5 },
  { name: "Ratón",   price: 29.99, stock: 0 },
  { name: "Monitor", price: 349.0, stock: 2 }
]
```

### Ejercicio 3 — Módulo mixin

Crea un módulo `Auditable` con métodos `created_info` y `updated_info` que devuelvan strings con timestamps. Inclúyelo en una clase `Task`.

---

## Solución

Ver [`ejercicios/solucion/modulo01.rb`](./ejercicios/solucion/modulo01.rb)
